# Scaling: Redis and multiple replicas

**Most users don't need this.** The template runs one LiteLLM replica with one worker, which
handles typical personal and small-team traffic, and keeps budgets and rate limits exact
without Redis.

Add Redis only when you run **more than one replica** or set `NUM_WORKERS` above 1. Without
Redis, each copy keeps its own counters, so budgets and rate limits can be overshot
(for example, a 100 requests/minute limit across 4 copies can let 400 through).

Redis adds a third service to your bill. Check its memory in **Metrics** after a day.

## 1. Get your own copy of the template code

Redis needs two extra blocks in `config.yaml`, so you need your own copy of the repository:

1. In Railway, open the **LiteLLM** service → **Settings** → **Source**.
2. Next to **Upstream Repo**, click **Eject** and choose your GitHub account.

Railway creates a repository in your GitHub account and deploys from it from now on.

## 2. Add Redis

In your project canvas: **+ Create** → **Database** → **Redis**.

## 3. Point LiteLLM at Redis

On the **LiteLLM** service, add these variables. Check the exact variable names in your
Redis service's **Variables** tab and adjust if they differ:

| Variable | Value |
| --- | --- |
| `REDIS_HOST` | `${{Redis.REDISHOST}}` |
| `REDIS_PORT` | `${{Redis.REDISPORT}}` |
| `REDIS_PASSWORD` | `${{Redis.REDISPASSWORD}}` |

## 4. Turn on Redis in config.yaml

In your ejected repository, add to `config.yaml` (environment variables alone are not enough):

```yaml
router_settings:
  redis_host: os.environ/REDIS_HOST
  redis_port: os.environ/REDIS_PORT
  redis_password: os.environ/REDIS_PASSWORD

litellm_settings:
  # keep the existing set_verbose, json_logs and request_timeout lines
  cache: True
  cache_params:
    type: redis
    host: os.environ/REDIS_HOST
    port: os.environ/REDIS_PORT
    password: os.environ/REDIS_PASSWORD
```

`router_settings` shares routing state (cooldowns, usage-based routing). The cache block
shares rate limits, budgets and scheduled-job locks. Commit and push; Railway redeploys.

## 5. Scale up

LiteLLM service → **Settings** → **Deploy** → **Replicas**, and/or raise `NUM_WORKERS`.
Each extra replica or worker uses roughly as much memory as the first, so cost grows with it.

## Check that it works

```bash
curl https://<your-domain>/cache/ping -H "Authorization: Bearer sk-<virtual-key>"
```

A healthy setup reports `"status": "healthy"` and `"cache_type": "redis"`.

Reference: LiteLLM, "What Needs Redis", https://docs.litellm.ai/docs/proxy/redis_requirements
