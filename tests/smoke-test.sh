#!/usr/bin/env bash
# Smoke test for a LiteLLM proxy: health, model list, one chat completion, spend logged.
#
# Usage:
#   export LITELLM_API_KEY=sk-...          # a VIRTUAL key with a small budget, not the master key
#   export BASE_URL=https://your-app.up.railway.app   # default: http://127.0.0.1:4000
#   export MODEL=claude-haiku-5-5          # the public model name you added in the UI
#   bash tests/smoke-test.sh
#
# Cost: one short chat completion (a fraction of a US cent on a cheap model).

set -u
BASE_URL="${BASE_URL:-http://127.0.0.1:4000}"
BASE_URL="${BASE_URL%/}"
MODEL="${MODEL:-claude-haiku-5-5}"
SPEND_WAIT_SECONDS="${SPEND_WAIT_SECONDS:-120}"

if [ -z "${LITELLM_API_KEY:-}" ]; then
  echo "LITELLM_API_KEY is not set (use a virtual key, not the master key)." >&2
  exit 2
fi

failures=0
pass() { echo "PASS  $1"; }
fail() { echo "FAIL  $1"; failures=$((failures + 1)); }
auth=(-H "Authorization: Bearer ${LITELLM_API_KEY}")

echo "Testing ${BASE_URL} with model '${MODEL}'"

# 1. Health: proxy up and connected to Postgres
health=$(curl -s --max-time 15 "${BASE_URL}/health/readiness")
if echo "$health" | grep -q '"status":"healthy"' && echo "$health" | grep -q '"db":"connected"'; then
  pass "health/readiness: healthy, database connected"
else
  fail "health/readiness returned: ${health:-no response}"
fi

# 2. The key can see the model
models=$(curl -s --max-time 15 "${auth[@]}" "${BASE_URL}/v1/models")
if echo "$models" | grep -q "\"id\":\"${MODEL}\""; then
  pass "/v1/models lists '${MODEL}'"
else
  fail "/v1/models does not list '${MODEL}': $(echo "$models" | cut -c1-200)"
fi

# 3. Spend before the request
spend_of() {
  curl -s --max-time 15 "${auth[@]}" "${BASE_URL}/key/info" \
    | grep -o '"spend":[0-9.eE+-]*' | head -1 | cut -d: -f2
}
spend_before=$(spend_of)
spend_before=${spend_before:-0}

# 4. One chat completion
body=$(printf '{"model":"%s","max_tokens":64,"messages":[{"role":"user","content":"Reply with exactly the word: pong"}]}' "$MODEL")
resp=$(curl -s --max-time 120 -w '\n%{http_code}' "${auth[@]}" -H "Content-Type: application/json" \
  -d "$body" "${BASE_URL}/v1/chat/completions")
code=$(echo "$resp" | tail -n1)
json=$(echo "$resp" | sed '$d')
if [ "$code" = "200" ] && echo "$json" | grep -qi 'pong'; then
  pass "chat completion: HTTP 200, model replied"
else
  fail "chat completion: HTTP ${code}: $(echo "$json" | cut -c1-300)"
fi

# 5. Spend is recorded (spend is written in batches, so this can take up to ~60 s)
if [ "$code" = "200" ]; then
  waited=0
  spend_after=$spend_before
  while [ "$waited" -le "$SPEND_WAIT_SECONDS" ]; do
    spend_after=$(spend_of); spend_after=${spend_after:-0}
    if awk -v a="$spend_after" -v b="$spend_before" 'BEGIN{exit !(a>b)}'; then break; fi
    sleep 10; waited=$((waited + 10))
  done
  if awk -v a="$spend_after" -v b="$spend_before" 'BEGIN{exit !(a>b)}'; then
    pass "spend recorded on key: \$${spend_before} -> \$${spend_after}"
  else
    fail "spend did not increase within ${SPEND_WAIT_SECONDS}s (still \$${spend_after})"
  fi
fi

echo
if [ "$failures" -eq 0 ]; then echo "ALL CHECKS PASSED"; exit 0; else echo "${failures} CHECK(S) FAILED"; exit 1; fi
