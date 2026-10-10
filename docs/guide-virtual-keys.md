# One key per app, with a monthly budget

Virtual keys let you give every app, teammate or client its own `sk-...` key. Each key can be
limited to certain models, a budget that resets on a schedule, and rate limits. Spend is
tracked per key. Your provider keys never leave the proxy.

## In the admin UI

1. Log in at `https://<your-domain>/ui` (username `admin`, password = `LITELLM_MASTER_KEY`).
2. Open **Virtual Keys** → **Create New Key**.
3. Set:
   - **Key name:** e.g. `open-webui`, `n8n`, `client-acme`
   - **Models:** only the models this app should use
   - **Max budget (USD):** e.g. `10`
   - **Budget duration / reset:** e.g. `30d` for a monthly budget
   - Optional: requests per minute (RPM) and tokens per minute (TPM) limits, and an expiry
4. Click **Create Key** and copy the key. It is shown only once.

When a key reaches its budget, the proxy rejects its requests until the budget resets.

## With the API

Use the master key to create keys from a script:

```bash
curl https://<your-domain>/key/generate \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "key_alias": "client-acme",
    "models": ["gpt-4o-mini"],
    "max_budget": 10,
    "budget_duration": "30d",
    "rpm_limit": 60
  }'
```

Check a key's spend (the key can check itself):

```bash
curl https://<your-domain>/key/info \
  -H "Authorization: Bearer sk-<virtual-key>"
```

## Using a virtual key in an app

Any OpenAI-compatible client works. Set:

- **Base URL:** `https://<your-domain>/v1`
- **API key:** the virtual key
- **Model:** the public model name from the **Models** page

Python example:

```python
from openai import OpenAI

client = OpenAI(base_url="https://<your-domain>/v1", api_key="sk-<virtual-key>")
reply = client.chat.completions.create(
    model="<public-model-name>",
    messages=[{"role": "user", "content": "Hello"}],
)
print(reply.choices[0].message.content)
```

## Good practice

- One key per app or person, so you can see who spends what and revoke one without
  affecting the others.
- Always set a budget. A small budget limits the damage if a key leaks.
- Delete keys you no longer use (**Virtual Keys** → select the key → delete).
- Budgets and rate limits are exact with the default single replica. If you scale to
  several replicas, add Redis (see [guide-scaling-redis.md](guide-scaling-redis.md)).
