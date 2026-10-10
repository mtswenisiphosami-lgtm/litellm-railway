# Use LiteLLM in n8n

n8n's AI nodes can use LiteLLM as their OpenAI endpoint, so your workflows can call any model
you added in LiteLLM, with spend tracked per virtual key.

## Before you start

- At least one model added in LiteLLM ([guide-provider-keys.md](guide-provider-keys.md))
- A virtual key for n8n with a budget ([guide-virtual-keys.md](guide-virtual-keys.md))

## 1. Create an OpenAI credential that points at LiteLLM

1. In n8n, open **Credentials** → **Add credential** → **OpenAI**.
2. **API Key:** your LiteLLM virtual key.
3. **Base URL:** `https://<your-domain>/v1`
   - If n8n runs in the same Railway project, use the private address instead:
     `http://<litellm-private-domain>:4000/v1` (find the private domain under the LiteLLM
     service's **Settings** → **Networking**). If that fails, add the variable `HOST` = `::`
     to the LiteLLM service and redeploy (Railway's private network may need IPv6), or use
     the public URL.
4. Leave **Organization ID** empty and save.

## 2. Use it in a workflow

1. Add an **AI Agent** (or **Basic LLM Chain**) node.
2. Attach an **OpenAI Chat Model** sub-node and select the credential from step 1.
3. **Model:** choose "By ID" (or "Expression") and enter the LiteLLM **public model name**
   exactly, for example `claude-haiku-5-5`. The model list may show OpenAI names, which
   only work if you added those models in LiteLLM.

## Notes

- Use the **OpenAI Chat Model** sub-node. Older reports say the standalone OpenAI node
  doesn't honour a custom base URL; check this on your n8n version before relying on it.
- Each workflow run is tracked in LiteLLM under the virtual key. Give busy workflows
  their own key and budget so a loop can't run up a large bill.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| Credential test fails | Check the Base URL ends with `/v1` and n8n can reach the domain |
| Model not found | Use the exact public model name from LiteLLM's **Models** page |
| 401 / budget exceeded | Check the virtual key's budget in LiteLLM **Virtual Keys** |
