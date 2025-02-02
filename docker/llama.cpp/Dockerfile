# Final stage with prebuilt binaries and runtime dependencies
FROM nvcr.io/nvidia/cuda:12.4.1-base-ubuntu22.04

ARG LLAMA_CPP_RELEASE="b4615"

LABEL org.opencontainers.image.source=https://github.com/abhinand5/LlamaPod.git
LABEL org.opencontainers.image.description="Run any GGUF model locally (or on Cloud) with a ChatGPT-like UI using llama.cpp and Docker"
LABEL org.opencontainers.image.licenses=MIT

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}

WORKDIR /workspace

# Install runtime dependencies including unzip
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    libcurl4 \
    software-properties-common

RUN add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    python3.11-dev
    
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --set python3 /usr/bin/python3.11 \
    && ln -sf /usr/bin/python3 /usr/bin/python
    
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    libcublas-12-4

RUN pip install --no-cache-dir huggingface_hub[cli] hf_transfer tqdm \
    && apt-get remove -y software-properties-common \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cu121

RUN pip install --no-cache-dir open-webui

# Download and install prebuilt binaries with shared libraries
RUN curl -LO https://github.com/ggerganov/llama.cpp/releases/download/${LLAMA_CPP_RELEASE}/llama-${LLAMA_CPP_RELEASE}-bin-ubuntu-x64.zip \
    && unzip llama-${LLAMA_CPP_RELEASE}-bin-ubuntu-x64.zip -d /tmp \
    && mv /tmp/build/bin/llama-* /usr/local/bin/ \
    && mv /tmp/build/bin/*.so /usr/local/lib/ \
    && ldconfig \
    && rm -rf /tmp/build llama-${LLAMA_CPP_RELEASE}-bin-ubuntu-x64.zip

# Set environment variables
ENV HF_HUB_ENABLE_HF_TRANSFER=1
ENV PATH="/usr/local/bin:$PATH"
ENV DATA_DIR="/workspace/.open-webui"
ENV OPENAI_API_BASE_URL="http://127.0.0.1:8081/v1"

# Copy scripts
COPY scripts/download.py /usr/src/download.py
COPY docker/llama.cpp/entrypoint.sh /usr/src/entrypoints/entrypoint.sh
COPY docker/llama.cpp/entrypoint-only-server.sh /usr/src/entrypoints/entrypoint-only-server.sh
RUN chmod +x /usr/src/entrypoints/entrypoint.sh
RUN chmod +x /usr/src/entrypoints/entrypoint-only-server.sh

EXPOSE 8080 8081

ENTRYPOINT ["/usr/src/entrypoints/entrypoint.sh"]
