#!/bin/bash

# Function to download model if HF repo is specified
download_model() {
    if [ ! -z "$HF_MODEL_ID" ]; then
        echo "Downloading model from Hugging Face: $HF_MODEL_ID"
        # Download the model
        python3 /usr/src/download.py --repo_id "$HF_MODEL_ID" --local_dir "$MODEL_DIR" --patterns "$MODEL_PATTERN"
    fi
}

# Function to start llama-server
start_llama_server() {
    echo "Starting llama-server..."
    llama-server --host 0.0.0.0 --port 8081 --model "$MODEL_PATH" "$@" &
    LLAMA_PID=$!
    echo "llama-server started with PID: $LLAMA_PID"
}

# Function to start open-webui
start_open_webui() {
    echo "Starting open-webui..."
    # Wait for llama-server to be ready
    sleep 5
    OPENWEBUI_PORT=${OPENWEBUI_PORT:-8080}
    open-webui serve --host 0.0.0.0 --port $OPENWEBUI_PORT &
    WEBUI_PID=$!
    echo "open-webui started with PID: $WEBUI_PID"
}

# Function to handle process termination
cleanup() {
    echo "Cleaning up processes..."
    kill $LLAMA_PID $WEBUI_PID 2>/dev/null
    exit 0
}

# Set up signal handling
trap cleanup SIGTERM SIGINT

# Start services
download_model
start_llama_server "$@"
start_open_webui

# Monitor child processes
wait $LLAMA_PID $WEBUI_PID

