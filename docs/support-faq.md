# Support FAQ

Answers to common questions about this template. For LiteLLM itself, see
https://docs.litellm.ai/docs/.

## Getting started

**How do I log in to the admin UI?**
Open `https://<your-domain>/ui`. Username: `admin`. Password: the value of
`LITELLM_MASTER_KEY` in the LiteLLM service's **Variables** tab.

**Where is my URL?**
LiteLLM service → **Settings** → **Networking** → the `*.up.railway.app` domain.

**I deployed it. Why can't I chat yet?**
The template has no models until you add one with your provider API key:
[guide-provider-keys.md](guide-provider-keys.md).

**Which base URL do I give my apps?**
`https://<your-domain>/v1`, with a virtual key as the API key
([guide-virtual-keys.md](guide-virtual-keys.md)).

## Errors

**The deploy failed or the service keeps restarting.**
Open the LiteLLM service → **Deployments** → the failed deploy → **View logs**. Common causes:
- `LITELLM_MASTER_KEY` is empty or set to a well-known value like `sk-1234`. LiteLLM refuses
  to start; set a long random value starting with `sk-`.
- Postgres isn't running. Check the Postgres service is online, then redeploy LiteLLM.

**401 Unauthorized / "Authentication Error".**
The key is wrong, expired, deleted, or not allowed to use that model. Check it under
**Virtual Keys**.

**"Budget exceeded".**
The key reached its `max_budget`. Raise the budget or wait for `budget_duration` to reset it.

**"Model not found" / "Invalid model name".**
Use the **public model name** from the LiteLLM **Models** page, exactly.

**My provider keys stopped working after I changed variables.**
`LITELLM_SALT_KEY` was changed. Set it back to the original value if you still have it;
otherwise re-enter every provider key in **Models**. Never change the salt key after adding
models.

**Spend shows $0 for a model.**
The model isn't in LiteLLM's price list yet. Edit the model and set input/output cost per token.

**The admin UI shows a warning about Redis.**
It's informational. With one replica and `NUM_WORKERS=1` you don't need Redis. To hide it,
add the variable `LITELLM_DISABLE_NO_REDIS_WARNING` = `true`. If you scale up, follow
[guide-scaling-redis.md](guide-scaling-redis.md).

## Cost

**How much does it cost?**
About $7.40 per month on Railway at idle (mostly LiteLLM's ~0.66 GB of memory), more with
heavy traffic. AI usage is billed separately by your providers. On the Hobby plan the
first $5 of usage each month is included.

**Why no Redis?**
A single replica doesn't need it, and leaving it out saves a third service. Add it only when
scaling to several replicas or workers.

**Can I make it cheaper?**
Keep `NUM_WORKERS=1` and one replica. Delete old spend logs if the database grows. Set a usage
limit in Railway (**Workspace** → **Usage** → **Set Usage Limits**) so a mistake can't cost much.

## Security

**Is the database exposed to the internet?**
No. Postgres has no public domain; LiteLLM reaches it over Railway's private network.

**Who can use my proxy?**
Only people with a valid key. Keep the master key to yourself and give each app its own
virtual key with a budget.

**How do I rotate the master key?**
Change `LITELLM_MASTER_KEY` and redeploy. Existing virtual keys keep working. Do not change
`LITELLM_SALT_KEY` at the same time.

## Updates

**Which LiteLLM version does this run, and why?**
See [VERSION_NOTES.md](../VERSION_NOTES.md): the pinned version, the security reasons for
choosing it, and how it was tested.

**How do I get updates?**
When the template is updated, Railway shows an update notice in your project. Updates are
opt-in: read `VERSION_NOTES.md` first, then apply. If you ejected the service to your own
repository, updates arrive as a branch you can review.

**Can I change the LiteLLM version myself?**
Yes, after ejecting: edit the `FROM` line in the `Dockerfile`. Always use an exact version
and check LiteLLM's security advisories first.
