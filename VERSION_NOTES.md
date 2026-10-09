# Version notes

## Current pinned version

| Item | Value |
| --- | --- |
| LiteLLM version | **v1.104.1** |
| Image | `ghcr.io/berriai/litellm:v1.104.1` |
| Digest | `sha256:501909ec6f504551f263f82fe8c53cfa34679d5753de507a2df69680a6021ad8` |
| Released | 2026-10-07 |
| Chosen on | 2026-10-09 |
| Platforms | linux/amd64, linux/arm64 |

The Dockerfile pins both the tag and the digest
(`ghcr.io/berriai/litellm:v1.104.1@sha256:5019…1ad8`). The digest guarantees that
every deploy pulls exactly the image that was tested, even if the tag were ever moved.

## Why this version

1. **LiteLLM's own production advice.** The release-cycle docs say: "In production, we
   recommend pinning to the latest stable `1.x.x` release." On 2026-10-09 the latest
   stable minor line is 1.104 (1.104.0 promoted from release candidate on 2026-10-03).
2. **All published security advisories are fixed.** 16 GitHub security advisories were
   published for LiteLLM in 2026 (4 critical). Every one is patched at or below 1.104.0.
   The most recent critical one, GHSA-7hp6-4w63-5g45 (2026-09-30, privilege escalation
   to proxy admin by reusing the salt key), is fixed in all 1.104.x releases. This matters
   for this template because it relies on `LITELLM_SALT_KEY`.
3. **After the March 2026 supply-chain incident.** The PyPI packages litellm 1.82.7 and
   1.82.8 were compromised on 2026-03-24. LiteLLM states the official Docker image was not
   affected. Clean releases resumed with v1.83.0 (2026-03-30) on a rebuilt CI/CD pipeline,
   and Docker images on GHCR have been cosign-signed since then. v1.104.1 is more than 20
   minor versions later and is a signed image.
4. **Safer defaults built in.** Since 1.104.0 the proxy refuses to start with an unset,
   empty or publicly known master key (such as `sk-1234`).
5. **Maintenance-only patch.** 1.104.1 = 1.104.0 plus a dependency refresh and a pgbouncer
   bump to 1.26.0. 1.104.2 (2026-10-08) was not chosen: it only adds a new feature
   backport ("Decisions") that this template doesn't need, contains no extra security
   fixes, and was one day old at the time of choosing.

## Registry

`ghcr.io/berriai/litellm` and `docker.litellm.ai/berriai/litellm` serve the identical
image for v1.104.1 (same digest, checked 2026-10-09). GHCR is used because LiteLLM's
release notes give the cosign verification instructions for GHCR.

## How it was tested

- [x] Cosign signature verified against LiteLLM's public key (commit `0112e53`), 2026-10-09
- [x] Local test with Postgres 17.2 (docker compose), 2026-10-09: readiness healthy and DB
      connected in under 45 s; admin UI login; `claude-haiku-5-5` added in the UI (provider
      key stored encrypted); virtual key with $1 budget; `tests/smoke-test.sh` and
      `tests/smoke-test.ps1` both pass; spend logged to the key and `LiteLLM_SpendLogs`;
      proxy restarted and the stored key still decrypted. Idle memory: ~625 MB proxy,
      ~100 MB Postgres.
- Note: the built-in price list in v1.104.1 does not include `claude-haiku-5-5`, but the
  proxy downloads LiteLLM's current price list at startup, which does (checked 2026-10-09).
- [ ] Railway deploy, restart and redeploy; stored keys still decrypt (Phase 5)
- [ ] 10/10 fresh template deploys (Phase 7)

## Sources (checked 2026-10-09)

- Releases: https://github.com/BerriAI/litellm/releases/tag/v1.104.1
- Security advisories: https://github.com/BerriAI/litellm/security/advisories
- Release cycle: https://docs.litellm.ai/docs/proxy/release_cycle
- March 2026 incident: https://docs.litellm.ai/blog/security-update-march-2026
- Production guide: https://docs.litellm.ai/docs/proxy/prod

## History

| Date | Version | Reason |
| --- | --- | --- |
| 2026-10-09 | v1.104.1 | Initial pin |
