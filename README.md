# LiteLLM on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/litellm-1?referralCode=HOJlTX&utm_medium=integration&utm_source=button&utm_campaign=litellm)

A low-cost, secure Railway template for the [LiteLLM](https://github.com/BerriAI/litellm) proxy
(AI gateway): one OpenAI-compatible endpoint in front of OpenAI, Anthropic and 100+ other
providers, with per-app virtual keys, budgets and spend tracking.

## What you get

- **LiteLLM v1.104.1**: the official image, pinned by tag and digest and signature-verified
  ([VERSION_NOTES.md](VERSION_NOTES.md))
- **Postgres** for keys, models, budgets and spend logs, on Railway's private network only,
  with a volume so data survives restarts
- **No Redis by default.** One replica doesn't need it, which keeps the bill low
- **Safe defaults:** master key, salt key and database password generated fresh per deploy;
  readiness health check; quiet production logging
- **Tested:** 10 out of 10 fresh template deploys succeeded before publishing

## Quick start

1. Click **Deploy on Railway** and wait for both services to be online (2-5 minutes).
2. LiteLLM service → **Variables** → copy `LITELLM_MASTER_KEY`.
3. Open `https://<your-domain>/ui`, log in as `admin` with that key.
4. **Models** → **Add Model** with your provider API key.
5. **Virtual Keys** → **Create New Key** with a budget for each app.
6. Point your app at `https://<your-domain>/v1` with the virtual key.

## Guides

- [Add provider API keys and models](docs/guide-provider-keys.md)
- [One key per app, with a monthly budget](docs/guide-virtual-keys.md)
- [Cursor](docs/guide-cursor.md)
- [Open WebUI](docs/guide-open-webui.md)
- [n8n](docs/guide-n8n.md)
- [Scaling with Redis and replicas](docs/guide-scaling-redis.md) (most users don't need this)
- [Support FAQ](docs/support-faq.md)
- [Template variables reference](docs/template-variables.md)

## Monthly cost

Measured on Railway over 24 hours (2026-10-09 to 2026-10-10) with the proxy idle:

| Resource | Average use | Monthly cost |
| --- | --- | --- |
| LiteLLM memory | 0.66 GB | $6.61 |
| LiteLLM CPU | 0.004 vCPU | $0.08 |
| Postgres memory | 0.07 GB | $0.66 |
| Postgres CPU | < 0.001 vCPU | $0.01 |
| Postgres volume | 0.2 GB | $0.03 |
| **Total** | | **≈ $7.40 / month** |

Prices: RAM $10/GB/month, CPU $20/vCPU/month, volume $0.15/GB/month (Railway, October
2026). Railway's actual bill for the same period matched (≈ $0.25/day). Usage grows with
traffic, so treat this as the starting cost. AI provider charges are billed separately by
each provider.

## Security and updates

- Only exact, signature-checked LiteLLM versions are used, never `latest`.
- LiteLLM releases and security advisories are checked weekly. A new version is pinned only
  after it passes local tests and fresh Railway deploys, and the reasons are recorded in
  [VERSION_NOTES.md](VERSION_NOTES.md).
- Updates reach your project as an opt-in notice from Railway.
- Images come from GitHub's container registry (ghcr.io), not Docker Hub, so Docker Hub rate
  limits and outages don't block deploys.

## Testing a deployment

```bash
export BASE_URL=https://your-app.up.railway.app
export LITELLM_API_KEY=sk-...   # a virtual key with a small budget, not the master key
export MODEL=your-model-name
bash tests/smoke-test.sh
```

Windows PowerShell: set `$env:BASE_URL`, `$env:LITELLM_API_KEY` and `$env:MODEL`, then run
`powershell -ExecutionPolicy Bypass -File tests\smoke-test.ps1`.

## Local testing (optional)

```bash
cp .env.example .env   # then fill in the three values (commands are in the file)
docker compose up -d --build
# open http://localhost:4000/ui
docker compose down -v
```

## License and credits

LiteLLM is developed by [BerriAI](https://github.com/BerriAI/litellm). This repository only
contains deployment configuration and documentation for running it on Railway.
