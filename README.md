# LiteLLM on Railway

A low-cost, secure Railway template for the [LiteLLM](https://github.com/BerriAI/litellm) proxy
(AI gateway): one OpenAI-compatible endpoint in front of OpenAI, Anthropic and 100+ other
providers, with per-app virtual keys, budgets and spend tracking.

> Work in progress. The Deploy button, setup guides and full documentation are added
> before the template is published.

## What you get

- **LiteLLM v1.104.1**, the official image, pinned by tag and digest and signature-verified
  ([VERSION_NOTES.md](VERSION_NOTES.md))
- **Postgres** for keys, models, budgets and spend logs (private network only)
- **No Redis by default.** One replica doesn't need it, which keeps the bill low.
- Secrets generated per deploy, a health check, and production settings pre-set

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
traffic, so treat this as the starting cost. AI provider charges (OpenAI, Anthropic, ...) are
billed separately by each provider.

## Testing a deployment

```bash
export BASE_URL=https://your-app.up.railway.app
export LITELLM_API_KEY=sk-...   # a virtual key with a small budget, not the master key
bash tests/smoke-test.sh
```

Windows PowerShell: set `$env:BASE_URL` and `$env:LITELLM_API_KEY`, then run
`powershell -ExecutionPolicy Bypass -File tests\smoke-test.ps1`.
