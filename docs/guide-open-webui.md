# Use LiteLLM with Open WebUI

[Open WebUI](https://docs.openwebui.com) is a self-hosted ChatGPT-style interface. Connected
to LiteLLM, it shows every model you added in the LiteLLM UI, and all chats are tracked
against one virtual key with a budget.

## Before you start

- At least one model added in LiteLLM ([guide-provider-keys.md](guide-provider-keys.md))
- A virtual key for Open WebUI with a budget ([guide-virtual-keys.md](guide-virtual-keys.md))

## Option A: in the Open WebUI admin settings

1. Log in to Open WebUI as an admin.
2. Go to **Settings** → **Admin** → **Connections**.
3. Under **Manage OpenAI API Connections**, click **+ Add Connection**.
4. **URL:** `https://<your-domain>/v1`
5. **API Key:** your LiteLLM virtual key
6. Click **Save**.

Open WebUI reads the model list from LiteLLM automatically. Start a new chat and pick a model.

## Option B: Open WebUI on Railway, in the same project

If you run Open WebUI as another service in the same Railway project, connect it over
Railway's private network instead of the public internet. Set these variables on the Open
WebUI service:

| Variable | Value |
| --- | --- |
| `OPENAI_API_BASE_URL` | `http://${{LiteLLM.RAILWAY_PRIVATE_DOMAIN}}:4000/v1` |
| `OPENAI_API_KEY` | your LiteLLM virtual key |

If Open WebUI can't reach LiteLLM this way, Railway's private network may need LiteLLM to
listen on IPv6: add the variable `HOST` = `::` to the LiteLLM service and redeploy, or simply
use the public URL from Option A.

Note: Open WebUI saves connection settings in its own database on first start. If you change
these variables later and nothing happens, edit the connection in **Admin** → **Connections**
instead.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| No models appear | Check the URL ends with `/v1` and that the virtual key is allowed to use those models |
| "Verify connection" shows an error but chat works | This can happen with some providers. Try a chat. |
| 401 errors | The key is wrong, expired, or over budget. Check **Virtual Keys** in LiteLLM |
| Model list times out | Raise `AIOHTTP_CLIENT_TIMEOUT_MODEL_LIST` on Open WebUI |
