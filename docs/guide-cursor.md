# Use LiteLLM from Cursor

Cursor can send chat requests to your LiteLLM proxy through its "Override OpenAI Base URL"
setting. Your Railway domain is public, so Cursor can reach it (Cursor cannot use
`localhost` addresses).

## Before you start

- A model added in the LiteLLM UI ([guide-provider-keys.md](guide-provider-keys.md))
- A virtual key for Cursor with a budget ([guide-virtual-keys.md](guide-virtual-keys.md))

## Setup

1. Open **Cursor Settings** → **Models**.
2. Scroll to **API Keys** → **OpenAI API Key**.
3. Paste your **LiteLLM virtual key** into the OpenAI API key field.
4. Turn on **Override OpenAI Base URL** and enter `https://<your-domain>/v1`.
5. Add a model: type the **public model name** exactly as it appears on the LiteLLM
   **Models** page (for example `claude-haiku-5-5`), and enable it.
6. Click **Verify**, then pick the model in the chat panel.

Cursor's menus change often. If a label differs, look for the OpenAI API key and base URL
settings under Models.

## What to expect

- Chat requests to the models you added go through LiteLLM and appear in its spend logs.
- Tab autocomplete and Cursor's own built-in models keep using Cursor's servers.
- Whether Agent mode works with your own key depends on your Cursor version and plan.
  Test it before relying on it.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| "Invalid API key" | Use the virtual key, check it hasn't expired or hit its budget |
| Model not found | The model name in Cursor must match the LiteLLM public model name exactly |
| No response / stalls | Check the URL ends with `/v1`. In Cursor settings, try HTTP compatibility mode HTTP/1.1 |
| Requests not in LiteLLM logs | The model you picked is a Cursor built-in model, not the one you added |
