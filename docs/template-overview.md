# Deploy and Host LiteLLM with Railway

LiteLLM is an open-source AI gateway: one OpenAI-compatible endpoint in front of OpenAI,
Anthropic, Google, Mistral and 100+ other providers. This template runs the LiteLLM proxy
with Postgres, so you get an admin UI, virtual keys with budgets and spend tracking from
the first deploy, starting at about $7.40 a month on Railway.

## About Hosting LiteLLM

Hosting LiteLLM means running the proxy server and a Postgres database for its keys, models,
budgets and spend logs. This template uses the official LiteLLM image, pinned to v1.104.1 by
tag and digest and checked against LiteLLM's published signature. Secrets (master key, salt
key, database password) are generated fresh for every deploy, the database is reachable
only over Railway's private network, and the proxy has a readiness health check so a bad
deploy never takes traffic. You add models and provider API keys in the admin UI at `/ui`;
they are stored encrypted in Postgres and survive restarts and redeploys. Redis is
deliberately left out: one replica doesn't need it, which keeps the bill low.

## Common Use Cases

- Give each app, teammate or client its own API key with a monthly budget, instead of sharing one provider key
- Switch between OpenAI, Anthropic and other models without changing application code
- Connect chat UIs and tools (Open WebUI, Cursor, n8n, LangChain, any OpenAI SDK) to many providers through one endpoint
- Track AI spend per key, per model and per team in one place

## Dependencies for LiteLLM Hosting

- LiteLLM proxy (official image `ghcr.io/berriai/litellm`, v1.104.1)
- PostgreSQL (Railway Postgres with a volume)
- At least one AI provider API key (OpenAI, Anthropic, ...), added after deploy in the admin UI

### Deployment Dependencies

- LiteLLM documentation: https://docs.litellm.ai/docs/
- LiteLLM releases and security advisories: https://github.com/BerriAI/litellm/releases
- Template source and setup guides: https://github.com/mtswenisiphosami-lgtm/litellm-railway

### Implementation Details

After the deploy finishes:

1. Open the **LiteLLM** service, **Variables** tab, and copy `LITELLM_MASTER_KEY`.
2. Go to `https://<your-domain>/ui` and log in with username `admin` and that key as the password.
3. **Models** → **Add Model**: choose your provider, the model, and paste your provider API key.
4. **Virtual Keys** → **Create New Key**: give each app its own key with a budget.
5. Point any OpenAI client at `https://<your-domain>/v1` with the virtual key.

```bash
curl https://<your-domain>/v1/chat/completions \
  -H "Authorization: Bearer sk-<virtual-key>" \
  -H "Content-Type: application/json" \
  -d '{"model": "<model-name>", "messages": [{"role": "user", "content": "Hello"}]}'
```

Cost, measured on Railway over 24 hours with the proxy idle: about 0.66 GB RAM for LiteLLM
and 0.07 GB for Postgres, roughly **$7.40 per month**. It grows with traffic. AI provider
charges are billed by each provider.

Security and updates: LiteLLM releases and security advisories are checked weekly. A new
version is only pinned after it passes local tests and fresh Railway deploys. The reasons
for each version are recorded in `VERSION_NOTES.md`, and Railway shows you an opt-in update
notice when the template changes.

### Why Deploy LiteLLM on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your
infrastructure so you don't have to deal with configuration, while allowing you to
vertically and horizontally scale it.

By deploying LiteLLM on Railway, you are one step closer to supporting a complete full-stack
application with minimal burden. Host your servers, databases, AI agents, and more on
Railway.
