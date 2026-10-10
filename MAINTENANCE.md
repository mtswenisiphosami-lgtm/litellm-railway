# Maintenance routine

How to keep the LiteLLM template secure, answer users, and collect earnings.
Published template: https://railway.com/deploy/litellm-1

## Weekly checklist (about 20-30 minutes)

- [ ] Run the update check (section 1) and decide whether an update is needed
- [ ] Answer new questions in the Template Queue (section 4)
- [ ] Glance at the template page: recent deploys look healthy, no new complaints
- [ ] Monthly: check earnings (section 5) and Railway usage (section 6)

Tip: you can ask Claude Code, opened in this folder, to "do the weekly maintenance check".

## 1. Security and release check

```bash
bash scripts/check-updates.sh
```

It shows the newest stable LiteLLM releases (marking any newer than the pinned version) and
the security advisories from the last 14 days, with the affected version ranges.

Decide like this:

| Situation | What to do |
| --- | --- |
| A **critical or high** advisory affects the pinned version | Update within a few days (section 2) |
| A medium/low advisory affects the pinned version | Update within about two weeks |
| A newer stable release, no advisory affecting the pinned version | No rush. Update roughly monthly, choosing a release that is at least a few days old |
| Only `-rc` or `-dev` releases are newer | Ignore them. Never pin release candidates or dev builds |
| News of a compromised LiteLLM release (like PyPI 1.82.7/1.82.8 in March 2026) | Check LiteLLM's security page before doing anything. Only use official, signed images (section 2, step 3) |

Read the release notes of the version you are considering and look for words like
"breaking", "removed", "migration" or "refuse to start".

## 2. Testing a new version

Cost: under $0.10 for the Railway part, plus a few cents of AI usage.

1. **Create a branch** for the update:
   ```bash
   git switch -c update-v1.x.y
   ```
2. **Find the image digest** (Docker Desktop must be running):
   ```bash
   docker buildx imagetools inspect ghcr.io/berriai/litellm:v1.x.y
   ```
   Copy the `Digest: sha256:...` line.
3. **Verify the signature.** It must say "The signatures were verified against the specified
   public key":
   ```bash
   docker run --rm ghcr.io/sigstore/cosign/cosign:v2.4.1 verify \
     --key https://raw.githubusercontent.com/BerriAI/litellm/0112e53046018d726492c814b3644b7d376029d0/cosign.pub \
     ghcr.io/berriai/litellm:v1.x.y@sha256:<digest>
   ```
4. **Edit the `FROM` line** in `Dockerfile` with the new tag and digest.
5. **Local test** (see README "Local testing"): `docker compose up -d --build`, check
   `http://localhost:4000/health/readiness`, log in to `/ui`, add a cheap model, create a
   virtual key with a $1 budget, and run `tests/smoke-test.sh`. Then `docker compose down -v`.
6. **Railway upgrade test.** This checks that existing users' data survives the upgrade:
   1. Deploy the published template into a new, temporary project (it runs the old version).
   2. Log in, add a model and a virtual key, and run the smoke test against it.
   3. Push your branch: `git push -u origin update-v1.x.y`.
   4. In the temporary project: LiteLLM service → **Settings** → **Source** → change the
      branch to `update-v1.x.y`. Railway redeploys with the new version. (If Railway doesn't
      let you change the branch, click **Eject** first and push your branch to the new repo.)
   5. Check the deploy log for errors and run the smoke test again. The model, key and
      spend must still be there.
   6. Delete the temporary project.
7. **Record it** in `VERSION_NOTES.md`: the new version, digest, date, why, and the tests
   passed. Add a row to the History table.

If anything fails, don't release. Stay on the current version and look into the problem
(LiteLLM's GitHub issues often already describe it).

## 3. Releasing the update

1. Merge the branch into `main` and push:
   ```bash
   git switch main
   git merge update-v1.x.y
   git push
   ```
2. Railway sees the change and shows existing template users an **opt-in update notice**.
   New deploys use the new version straight away.
3. Deploy the published template once more into a temporary project, confirm it is
   healthy, then delete it.
4. Only edit the template itself (workspace **Settings** → **Templates** → LiteLLM) if
   variables or service settings changed. Keep every variable's description.

## 4. Template Queue (support)

Answering questions is what raises the kickback from 15% to 25%.

- Queue: https://station.railway.com/my-template-queue (Railway also emails you new questions)
- Most answers are already in `docs/support-faq.md`. Copy, adapt, and link to the relevant guide.
- Ask for logs (with keys removed) when something fails. Never ask users to post keys.
  If someone posts a key publicly, tell them to rotate it.
- New question that isn't in the FAQ? Add the answer to `docs/support-faq.md`.
- Claude can draft answers: paste the question and ask for a reply based on the FAQ.

## 5. Earnings

- **Earnings page:** railway.com → account settings → **Earnings**.
- Kickback: 15% of the Railway usage of people who deploy your template, 25% while you
  actively support it.
- By default earnings become Railway credits. To collect cash, turn **off**
  "Direct Deposit to Railway Credits"; earnings then build up in your Available Balance.
- **Withdraw** through Stripe Connect in steps of $100 to $10,000. Complete Stripe's
  onboarding first and check it supports your South African bank account. If it doesn't,
  credits can still pay your own Railway bill.
- Keep a simple monthly record (date, amount, credits or cash) for your tax return.

## 6. Your own Railway projects and costs

- `litellm-template` is the original test project (about $0.25 a day, ~$7.40 a month). The
  published template does not depend on it. Section 2 uses temporary projects instead, so
  it can be deleted. If you delete it, also delete its Anthropic key
  (`litellm-railway`) at platform.claude.com.
- Workspace usage limits: soft $6, hard $10 (Workspace → Usage). If the hard limit is hit,
  **all** projects go offline, including other projects.
- Delete temporary test projects as soon as a test is done. Railway keeps deleted
  projects for 48 hours before removing them for good.

## 7. Never do this

- Never pin `latest`, `main-latest`, an `-rc` or a `-dev` image.
- Never change `LITELLM_SALT_KEY` in a running project: stored provider keys become unreadable.
- Never commit `.env`, keys or passwords. `gitleaks` can check:
  `MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd -W):/repo" zricethezav/gitleaks:v8.18.4 detect --source /repo --log-opts="--all" --redact`
- Never test new versions only on `main`. Use a branch, because `main` is what users deploy.
