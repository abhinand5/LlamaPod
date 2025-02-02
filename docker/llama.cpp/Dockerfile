# Builder stage for llama.cpp compilation
FROM nvcr.io/nvidia/cuda:12.4.1-devel-ubuntu22.04 AS builder

LABEL org.opencontainers.image.source=https://github.com/abhinand5/LlamaPod.git
LABEL org.opencontainers.image.description="Run any GGUF model locally (or on Cloud) with a ChatGPT-like UI using llama.cpp and Docker"
LABEL org.opencontainers.image.licenses=MIT

# Install minimal build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git build-essential cmake \
    libcurl4-openssl-dev gcc g++ make \
    && rm -rf /var/lib/apt/lists/*

# Build llama.cpp
WORKDIR /build
RUN git clone https://github.com/ggerganov/llama.cpp.git && \
    cmake llama.cpp -B llama.cpp/build -DBUILD_SHARED_LIBS=OFF -DGGML_CUDA=ON -DLLAMA_CURL=ON && \
    cmake --build llama.cpp/build --config Release -j --clean-first --target llama-cli llama-server

# Final stage with only runtime dependencies
FROM nvcr.io/nvidia/cuda:12.4.1-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

WORKDIR /workspace

# Install runtime dependencies in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libcurl4-openssl-dev \
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

RUN apt-get remove -y python3-blinker \
    && pip install --no-cache-dir -U blinker \
    && pip install --no-cache-dir open-webui

# Copy only necessary files from builder
COPY --from=builder /build/llama.cpp/build/bin/llama-* /usr/local/bin/

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
