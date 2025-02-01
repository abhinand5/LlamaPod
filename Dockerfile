# Builder stage for llama.cpp compilation
FROM nvcr.io/nvidia/cuda:12.4.1-devel-ubuntu22.04 AS builder

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

# Final stage
FROM nvcr.io/nvidia/cuda:12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

WORKDIR /workspace

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl libcurl4-openssl-dev \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y python3.11 python3.11-venv python3.11-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pip and set Python 3.11 as default
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --set python3 /usr/bin/python3.11 && \
    ln -sf /usr/bin/python3 /usr/bin/python

# Copy llama.cpp binaries from builder stage
COPY --from=builder /build/llama.cpp/build/bin/llama-* /usr/local/bin/

# Install Python dependencies
RUN pip install --no-cache --ignore-installed huggingface_hub[cli] hf_transfer open-webui

ENV PATH="/usr/local/bin:$PATH"
ENV DATA_DIR="/workspace/.open-webui"

EXPOSE 8080

# Copy the scripts
COPY download.py /workspace/download.py
COPY entrypoint.sh /workspace/entrypoint.sh

# Make entrypoint executable
RUN chmod +x /workspace/entrypoint.sh

ENTRYPOINT ["/workspace/entrypoint.sh"]

