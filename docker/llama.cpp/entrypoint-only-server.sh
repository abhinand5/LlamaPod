#!/bin/bash

# Download the model
python3 /workspace/download.py --repo_id "$REPO_ID" --local_dir "$MODEL_DIR" --patterns "$MODEL_PATTERN"

# Start the server with any additional arguments
exec llama-server --host 0.0.0.0 --port 8080 --model "$MODEL_PATH" "$@"
