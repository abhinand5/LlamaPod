import os
import argparse
import logging
from huggingface_hub import snapshot_download

# Enable fast Hugging Face transfer
os.environ["HF_HUB_ENABLE_HF_TRANSFER"] = "1"

# Configure logging
logging.basicConfig(level=logging.DEBUG, format="%(asctime)s - %(levelname)s - %(message)s")

def download_models(repo_id: str, local_dir: str, patterns: list | str | None):
    """
    Downloads models from Hugging Face with specified patterns.
    
    Args:
        repo_id (str): Hugging Face repository ID.
        local_dir (str): Directory to store downloaded models.
        patterns (list): List of file patterns to match.
    """
    try:
        logging.info(f"Starting download from {repo_id} into {local_dir} with patterns {patterns}")
        
        if patterns == "*" or patterns == "" or patterns is None:
            patterns = None

        snapshot_download(
            repo_id=repo_id,
            local_dir=local_dir,
            allow_patterns=patterns,
        )
        
        logging.info("Download completed successfully.")
    except Exception as e:
        logging.error(f"Download failed: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Download models from a Hugging Face repository.")
    parser.add_argument("--repo_id", required=True, help="Hugging Face repository ID (e.g., unsloth/DeepSeek-R1-GGUF)")
    parser.add_argument("--local_dir", required=True, help="Local directory to save the models")
    parser.add_argument("--patterns", nargs="+", required=False, help="File patterns to download (e.g., '*UD-IQ1_S*')", default=None)

    args = parser.parse_args()
    download_models(args.repo_id, args.local_dir, args.patterns)

