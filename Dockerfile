ARG BASE_IMAGE=nvidia/cuda:12.6.3-cudnn-runtime-ubuntu24.04

FROM ${BASE_IMAGE}
LABEL org.opencontainers.image.source="https://github.com/speaches-ai/speaches"
LABEL org.opencontainers.image.licenses="MIT"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates curl ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=ghcr.io/astral-sh/uv:0.8.22 /uv /bin/uv
COPY . .

ENV UV_CACHE_DIR=/app/.uv-cache
ENV UV_PYTHON_INSTALL_DIR=/app/.uv-python
RUN uv sync --frozen --compile-bytecode --extra ui --active

RUN chgrp -R 0 /app/.venv/bin/ && \
    chmod -R g=u  /app/.venv/bin/

ENV UVICORN_HOST=0.0.0.0
ENV UVICORN_PORT=8000
ENV PATH="/app/.venv/bin:$PATH"

ENV HF_HUB_ENABLE_HF_TRANSFER=0
ENV DO_NOT_TRACK=1
ENV GRADIO_ANALYTICS_ENABLED="False"
ENV DISABLE_TELEMETRY=1
ENV HF_HUB_DISABLE_TELEMETRY=1

EXPOSE 8000
CMD ["uvicorn", "--factory", "speaches.main:create_app"]
