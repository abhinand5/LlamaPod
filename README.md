# 🦙 LlamaPod

**Deploy and run any LLM model with a ChatGPT-like interface in minutes**

LlamaPod is a powerful, containerized solution for running open-source language models locally or in the cloud. It combines the efficiency of llama.cpp with an intuitive chat interface, making it easy to deploy and interact with state-of-the-art language models.

**Note:** Currently only supports GGUF. See [Roadmap](#️-roadmap) for more details.

## ✨ Key Features

- **Universal Model Support**: Run any GGUF model from Hugging Face with zero configuration
- **GPU Acceleration**: Optimized CUDA support for blazing-fast inference when GPUs are available
- **Dual Interface**: 
  - Modern web UI for interactive chat sessions
  - OpenAI-compatible API for seamless integration with existing applications
- **Resource Efficient**: Optimized for both CPU and GPU environments
- **Cloud Ready**: Pre-configured for deployment on RunPod, vast.ai, and other cloud platforms

## 🚀 Quick Start

### Llama.cpp

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

Visit:
- Web UI: http://localhost:8080
- API Endpoint: http://localhost:8081/v1

#### Using your external DB

If you need persistance, please follow this method. This external DB can be any Postgres instance, even free cloud hosted ones ones like [Supabase](https://supabase.com/docs/guides/database/overview).

```bash
docker run -it \
  -p 8080:8080 -p 8081:8081 --gpus all \
  -v ./models:/workspace/models \
  -e HF_MODEL_ID="bartowski/DeepSeek-R1-Distill-Qwen-1.5B-GGUF" \
  -e MODEL_DIR="/workspace/models" \
  -e MODEL_PATTERN="*f16.gguf" \
  -e DATABASE_URL="postgres://username:password@postgress-addr:5432/openwebui" \
  -e MODEL_PATH="/workspace/models/DeepSeek-R1-Distill-Qwen-1.5B-f16.gguf" \
  --add-host host.docker.internal:host-gateway \
  ghcr.io/abhinand5/llama-pod \
  --n-gpu-layers 28 --ctx-size 4096
```

### vLLM

(To be added)

## 🛠️ Installation Options

### Using Pre-built Image

```bash
# Pull the latest stable image
docker pull ghcr.io/abhinand5/llamapod:main

# Or use a specific version add your desired commit SHA from releases page
docker pull ghcr.io/abhinand5/llamapod:sha-d5017a7
```

### Building from Source

```bash
git clone https://github.com/abhinand5/LlamaPod.git
cd LlamaPod
docker build -f docker/llama.cpp/Dockerfile -t llama-pod .
```

## 🎮 Usage Guide

### Environment Variables

- `HF_MODEL_ID`: Hugging Face repository ID (e.g., "unsloth/DeepSeek-R1-GGUF")
- `MODEL_DIR`: Directory to store downloaded models
- `MODEL_PATTERN`: File pattern to match when downloading (e.g., "*Q4_K_M.gguf")
- `MODEL_PATH`: Full path to the model file
- `OPENWEBUI_PORT`: Port for the web interface (default: 8080)

### GPU Configuration

Adjust these parameters based on your GPU memory and requirements:

```bash
--n-gpu-layers <number>  # Number of layers to offload to GPU
--ctx-size <size>        # Context window size
```

For more details about `llama-server` parameters refer their [docs](https://github.com/ggerganov/llama.cpp/blob/master/examples/server/README.md).

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

- [ ] vLLM-based images for high-performance serving
- [ ] Alternative web UI integrations
- [ ] One-click deployment to major cloud platforms (AWS, GCP, Azure)
- [ ] DeepSeek R1 671B deployment guide
- [ ] Fine-grained configuration controls
- [ ] Enhanced monitoring and resource management
- [ ] Support for Apple Silicon with MLX
- [ ] Support for AMD GPUs

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📝 License

[MIT License](LICENSE)

## 🙏 Acknowledgments

Built with and grateful to:
- [llama.cpp](https://github.com/ggerganov/llama.cpp)
- [open-webui](https://github.com/open-webui/open-webui)
- NVIDIA CUDA Team
- The Hugging Face Team
- [Unsloth.ai](https://unsloth.ai/)

## 📫 Support & Community

- [GitHub Issues](https://github.com/abhinand5/LlamaPod/issues)
<!-- - [Discord Community](https://discord.gg/llamapod)
- [Documentation](https://llamapod.docs.com) -->

---

⭐ If you find LlamaPod useful, please consider starring the repository!
