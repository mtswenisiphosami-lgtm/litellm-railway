# Add provider API keys and models

Models and provider API keys are added in the LiteLLM admin UI. They are stored in Postgres,
encrypted with your `LITELLM_SALT_KEY`, and survive restarts and redeploys.

## 1. Log in to the admin UI

1. In Railway, open your project → **LiteLLM** service → **Variables**.
2. Copy the value of `LITELLM_MASTER_KEY` (starts with `sk-`).
3. Open `https://<your-domain>/ui` (your domain is under the service's **Settings** → **Networking**).
4. Log in with username `admin` and the master key as the password.

Keep the master key private. Give apps virtual keys instead (see
[guide-virtual-keys.md](guide-virtual-keys.md)).

## 2. Get an API key from your provider

- **OpenAI:** platform.openai.com → **API keys** → **Create new secret key**
- **Anthropic:** platform.claude.com → **API Keys** → **Create Key**

The provider needs API credit or billing set up. A ChatGPT or Claude chat subscription is
not the same as API credit.

## 3. Add a model

1. In the admin UI, open **Models** → **Add Model**.
2. **Provider:** e.g. OpenAI or Anthropic.
3. **Model:** pick the provider's model (e.g. `gpt-4o-mini` or `claude-haiku-5-5`). If it's
   not in the list, type the exact model ID from the provider's documentation.
4. **Public model name:** the name your apps will use. Using the same name as the
   provider's model ID is simplest.
5. **API key:** paste the provider key here (not in your app).
6. Click **Add Model**.

Repeat for each model you want to offer. You can add several deployments with the same
public name to load-balance between keys or providers.

## 4. Test it

In the UI, open the **Test Key** / **Playground** page, or use curl with a virtual key:

```bash
curl https://<your-domain>/v1/chat/completions \
  -H "Authorization: Bearer sk-<virtual-key>" \
  -H "Content-Type: application/json" \
  -d '{"model": "<public-model-name>", "messages": [{"role": "user", "content": "Say hello"}]}'
```

## Important

- **Never change `LITELLM_SALT_KEY`** after adding models. It encrypts the stored provider
  keys; with a different salt key they can no longer be decrypted and you would have to
  re-enter every key.
- To rotate a provider key, edit the model in **Models** and paste the new key, then revoke
  the old key at the provider.
- Spend tracking uses LiteLLM's price list, which the proxy downloads at startup, so newly
  released models are priced without updating the template. If a model shows $0 spend,
  set its price per token when editing the model.
