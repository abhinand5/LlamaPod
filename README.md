# LlamaPod 🦙

Run any GGUF model locally with a ChatGPT-like interface using llama.cpp and Docker - no GPU required, but GPU-accelerated when available.

## Features
- 🚀 One-click deployment of any GGUF model from Hugging Face
- 💻 GPU-accelerated inference with CUDA support
- 🌐 Clean web UI with chat interface
- 🔌 OpenAI-compatible API endpoints
- 📦 Containerized for easy deployment
- ☁️ Ready for RunPod deployment

## Quick Start
```bash
docker run -p 8080:8080 --gpus all \
  -e REPO_ID="unsloth/DeepSeek-R1-GGUF" \
  -e MODEL_DIR="/workspace/models" \
  -e MODEL_PATTERN="*Q4_K_M.gguf" \
  -e MODEL_PATH="/workspace/models/model.gguf" \
  abhinand05/llamapod \
  --n-gpu-layers 35 --ctx-size 4096
```

Visit [http://localhost:8080](http://localhost:8080) to access the web interface.

## License

[MIT License](https://mit-license.org/)
