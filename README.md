# 🦙 LlamaPod

<div align="center">

[![Build Status](https://github.com/abhinand5/LlamaPod/actions/workflows/docker-build.yml/badge.svg)](https://github.com/abhinand5/LlamaPod/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://makeapullrequest.com)
[![Docker Pulls](https://img.shields.io/docker/pulls/abhinand5/llama-pod)](https://github.com/abhinand5/LlamaPod/pkgs/container/llama-pod)

**Deploy and run any LLM model with a ChatGPT-like interface in minutes**

[Getting Started](#-quick-start) •
[Documentation](#-installation-options) •
[Contributing](#-contributing) •
[Support](#-support--community)

</div>

LlamaPod simplifies the deployment of open-source language models through Docker containers. With just a single command, you can run models using llama.cpp or vLLM backends, complete with a ChatGPT-like interface and API compatibility.

## 📌 Table of Contents
- [✨ Key Features](#-key-features)
- [🚀 Quick Start](#-quick-start)
- [🛠️ Installation Options](#️-installation-options)
- [🎮 Usage Guide](#-usage-guide)
- [🗺️ Roadmap](#️-roadmap)
- [🤝 Contributing](#-contributing)
- [📝 License](#-license)

## ✨ Key Features

- **Easy Deployment**: Run any LLM with a single Docker command - no complex setup required
- **Flexible Model Support**: 
  - llama.cpp backend for GGUF models
  - vLLM backend for HuggingFace models, GGUF, AWS checkpoints and more
- **GPU Acceleration**: Optimized CUDA support for blazing-fast inference when GPUs are available
- **Dual Interface**: 
  - Modern web UI for interactive chat sessions
  - OpenAI-compatible API for seamless integration with existing applications
- **Resource Efficient**: Optimized for both CPU and GPU environments
- **Cloud Ready**: Pre-configured for deployment on RunPod, vast.ai, and other cloud platforms

## 🚀 Quick Start

### Using llama.cpp Backend

```bash
docker run -it -p 8080:8080 --gpus all \
  -v $(pwd)/models:/workspace/models \
  -e HF_MODEL_ID="bartowski/DeepSeek-R1-Distill-Qwen-1.5B-GGUF" \
  -e MODEL_DIR="/workspace/models" \
  -e MODEL_PATTERN="*f16.gguf" \
  -e MODEL_PATH="/workspace/models/DeepSeek-R1-Distill-Qwen-1.5B-f16.gguf" \
  ghcr.io/abhinand5/llama-pod \
  --n-gpu-layers 28 --ctx-size 8192
```

### Using vLLM Backend (Experimental)

```bash
docker run -it -p 8080:8080 --gpus all \
  -v $(pwd)/models:/workspace/models \
  -e HF_MODEL_ID="bartowski/DeepSeek-R1-Distill-Qwen-1.5B-GGUF" \
  -e MODEL_DIR="/workspace/models" \
  -e MODEL_PATTERN="*f16.gguf" \
  -e MODEL_PATH="/workspace/models/DeepSeek-R1-Distill-Qwen-1.5B-f16.gguf" \
  ghcr.io/abhinand5/llamapod-vllm \
  --tensor-parallel-size 1 \
  --load-format gguf \
  --max-model-len 4096 \
  --gpu-memory-utilization 0.96 \
  --tokenizer deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B
```

Visit:
- Web UI: http://localhost:8080
- API Endpoint: http://localhost:8081/v1

### Using External Database

For persistence, you can use any Postgres instance, including free cloud-hosted ones like [Supabase](https://supabase.com/docs/guides/database/overview).

```bash
docker run -it \
  -p 8080:8080 -p 8081:8081 --gpus all \
  -v ./models:/workspace/models \
  -e HF_MODEL_ID="bartowski/DeepSeek-R1-Distill-Qwen-1.5B-GGUF" \
  -e MODEL_DIR="/workspace/models" \
  -e MODEL_PATTERN="*f16.gguf" \
  -e DATABASE_URL="postgres://username:password@host.docker.internal:5432/openwebui" \
  -e MODEL_PATH="/workspace/models/DeepSeek-R1-Distill-Qwen-1.5B-f16.gguf" \
  --add-host host.docker.internal:host-gateway \
  ghcr.io/abhinand5/llama-pod \
  --n-gpu-layers 28 --ctx-size 4096
```

Replace `host.docker.internal` with your instance's IP address or hostname.

## 🛠️ Installation Options

### Using Pre-built Images

```bash
# For llama.cpp backend
docker pull ghcr.io/abhinand5/llamapod:main
# or specific version
docker pull ghcr.io/abhinand5/llamapod:sha-d5017a7

# For vLLM backend (Experimental)
docker pull ghcr.io/abhinand5/llamapod-vllm:main
```

### Building from Source

```bash
git clone https://github.com/abhinand5/LlamaPod.git
cd LlamaPod

# Build llama.cpp version
docker build -f docker/llama.cpp/Dockerfile -t llama-pod .

# Build vLLM version
docker build -f docker/vllm/Dockerfile -t llama-pod-vllm .
```

## 🎮 Usage Guide

### Environment Variables

- `HF_MODEL_ID`: Hugging Face repository ID (e.g., "unsloth/DeepSeek-R1-GGUF")
- `MODEL_DIR`: Directory to store downloaded models
- `MODEL_PATTERN`: File pattern to match when downloading (e.g., "*Q4_K_M.gguf")
- `MODEL_PATH`: Full path to the model file
- `OPENWEBUI_PORT`: Port for the web interface (default: 8080)

### Backend-specific Configuration

#### llama.cpp
```bash
--n-gpu-layers <number>  # Number of layers to offload to GPU
--ctx-size <size>        # Context window size
```
For more details about `llama-server` parameters, refer to their [docs](https://github.com/ggerganov/llama.cpp/blob/master/examples/server/README.md).

#### vLLM (Experimental)
```bash
--tensor-parallel-size <number>  # Number of GPUs for tensor parallelism
--gpu-memory-utilization <float> # GPU memory usage (0.0 to 1.0)
```
For more vLLM parameters, check their [docs](https://docs.vllm.ai/en/latest/serving/openai_compatible_server.html#cli-reference).

### API Integration

LlamaPod provides an OpenAI-compatible API:

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8081/v1",
    api_key="none"
)

response = client.chat.completions.create(
    model="you-model-name-here",
    messages=[{"role": "user", "content": "Hello!"}]
)
```

## 🗺️ Roadmap

- [x] vLLM-based images for high-performance serving (Experimental)
- [ ] Docker compose files
- [ ] Alternative web UI integrations
- [ ] One-click deployment to major cloud platforms (AWS, GCP, Azure)
- [ ] DeepSeek R1 671B deployment guide
- [ ] Fine-grained configuration controls
- [ ] Enhanced monitoring and resource management
- [ ] Support for Apple Silicon with MLX
- [ ] Support for AMD GPUs
- [ ] UI for easy deployment across platforms and locally.

## 🤝 Contributing

We welcome contributions! Here's how you can help:

- 🐛 Report bugs by opening an issue
- 💡 Suggest new features or improvements
- 🔍 Review pull requests
- 📖 Improve documentation
- 🌟 Star the repository to show your support

Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📝 License

This project is licensed under the [MIT License](LICENSE).

## 🙏 Acknowledgments

Built with and grateful to:
- [llama.cpp](https://github.com/ggerganov/llama.cpp)
- [vLLM](https://github.com/vllm-project/vllm)
- [open-webui](https://github.com/open-webui/open-webui)
- NVIDIA CUDA Team
- The Hugging Face Team
- [Unsloth.ai](https://unsloth.ai/)

---

⭐ If you find LlamaPod useful, please consider starring the repository!
