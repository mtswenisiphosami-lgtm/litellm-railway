# Template variables

Values and descriptions used in the Railway template composer. No real secrets here:
the template generates fresh secrets on every deploy with `${{secret()}}`.

## LiteLLM service

| Variable | Template value | Description |
| --- | --- | --- |
| `LITELLM_MASTER_KEY` | `sk-${{secret(40, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")}}` | Admin key for the proxy, generated for you. It is also the admin UI password (username `admin`). Keep it private and use virtual keys for apps. |
| `LITELLM_SALT_KEY` | `${{secret(40, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")}}` | Encrypts the provider API keys stored in the database, generated for you. Never change it after adding models, or stored keys can no longer be decrypted. |
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Connection to the Postgres service over Railway's private network. Set automatically; no need to change it. |
| `STORE_MODEL_IN_DB` | `True` | Saves models you add in the admin UI to the database so they survive restarts and redeploys. |
| `PORT` | `4000` | Port the proxy listens on. Leave at 4000 unless you also change the public networking port. |
| `NUM_WORKERS` | `1` | Number of proxy worker processes. 1 is enough for most use; each extra worker uses more memory (and costs more). |
| `LITELLM_LOG` | `ERROR` | Log level. ERROR keeps logs small; set to INFO or DEBUG temporarily when troubleshooting. |
| `LITELLM_MODE` | `PRODUCTION` | Production mode: LiteLLM does not load a local .env file. Leave as is. |

## Service settings

| Setting | Value |
| --- | --- |
| Source | GitHub `mtswenisiphosami-lgtm/litellm-railway`, branch `main` (builds the Dockerfile) |
| Public networking | HTTP, port 4000 |
| Healthcheck path | `/health/readiness` |

## Postgres service

Railway's standard Postgres image (`ghcr.io/railwayapp-templates/postgres-ssl`) with its
volume mounted at `/var/lib/postgresql/data`. No public networking (private network only).

| Variable | Template value | Description |
| --- | --- | --- |
| `POSTGRES_PASSWORD` | `${{secret(32, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")}}` | Database password, generated for you on every deploy. |
| `POSTGRES_USER` | `postgres` | Database user name. |
| `POSTGRES_DB` | `railway` | Database name. |
| `PGPASSWORD` | `${{POSTGRES_PASSWORD}}` | Same as POSTGRES_PASSWORD, for Postgres client tools. |
| `PGUSER` | `${{POSTGRES_USER}}` | Same as POSTGRES_USER, for Postgres client tools. |
| `PGDATABASE` | `${{POSTGRES_DB}}` | Same as POSTGRES_DB, for Postgres client tools. |
| `PGHOST` | `${{RAILWAY_PRIVATE_DOMAIN}}` | Private network address of the database (not reachable from the internet). |
| `PGPORT` | `5432` | Database port. |
| `PGDATA` | `/var/lib/postgresql/data/pgdata` | Where Postgres stores its data inside the volume. Do not change. |
| `DATABASE_URL` | `postgresql://${{PGUSER}}:${{POSTGRES_PASSWORD}}@${{RAILWAY_PRIVATE_DOMAIN}}:5432/${{PGDATABASE}}` | Private connection string used by LiteLLM. Set automatically. |
| `RAILWAY_DEPLOYMENT_DRAINING_SECONDS` | `60` | Seconds Postgres gets to shut down cleanly during a redeploy. |
| `SSL_CERT_DAYS` | `820` | Validity in days of the database's self-signed SSL certificate. |
