# Official LiteLLM proxy image, pinned by tag AND digest (see VERSION_NOTES.md).
# The digest guarantees every deploy runs the exact image that was signature-checked and tested.
FROM ghcr.io/berriai/litellm:v1.104.1@sha256:501909ec6f504551f263f82fe8c53cfa34679d5753de507a2df69680a6021ad8

COPY config.yaml /app/config.yaml

# The image's entrypoint runs `litellm`. The port comes from the PORT variable (default 4000)
# and the worker count from NUM_WORKERS.
CMD ["--config", "/app/config.yaml"]
