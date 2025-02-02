FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

LABEL org.opencontainers.image.source=https://github.com/abhinand5/LlamaPod.git
LABEL org.opencontainers.image.description="Run any GGUF/AWQ/HF model locally with vLLM backend"
LABEL org.opencontainers.image.licenses=MIT

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHON_VERSION=3.11
ENV PATH="/usr/local/bin:$PATH"
ENV DATA_DIR="/workspace/.open-webui"
ENV OPENAI_API_BASE_URL="http://127.0.0.1:8081/v1"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    software-properties-common \
    build-essential

RUN add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-venv \
    python${PYTHON_VERSION}-dev

# Set up Python
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python${PYTHON_VERSION} \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1 \
    && update-alternatives --set python3 /usr/bin/python3.11 \
    && ln -sf /usr/bin/python3 /usr/bin/python

# Install vLLM and dependencies
RUN pip install --no-cache-dir --ignore-installed \
    huggingface_hub[cli] hf_transfer

RUN pip install --no-cache-dir --ignore-installed \
    --extra-index-url torch torchvision torchaudio

RUN apt-get install git -y --no-install-recommends \
    && git clone --depth=1 https://github.com/vllm-project/vllm.git \
    && cd vllm \
    && python use_existing_torch.py \
    && pip install --no-cache-dir -r requirements-build.txt \
    && pip install --no-cache-dir -e . --no-build-isolation

RUN pip install --no-cache-dir --ignore-installed open-webui

RUN apt-get remove -y software-properties-common \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Enable fast downloads from HuggingFace
ENV HF_HUB_ENABLE_HF_TRANSFER=1

WORKDIR /workspace

# Copy scripts and configurations
COPY scripts/download.py /workspace/download.py
COPY docker/vllm/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080 8081

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
