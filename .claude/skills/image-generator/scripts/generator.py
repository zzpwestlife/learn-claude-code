import os
import sys
import json
import time
import argparse
import requests
import hashlib
from datetime import datetime
from PIL import Image
from io import BytesIO

# Default configuration
DEFAULT_MODEL = "Tongyi-MAI/Z-Image-Turbo"
DEFAULT_API_KEY = "ms-41706221-999d-4fe6-8ee3-f3334f2069d1"
BASE_URL = "https://api-inference.modelscope.cn/"

def generate_filename(prompt, output_dir):
    """Generate a unique filename based on timestamp and prompt hash."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    # Create a short hash of the prompt to ensure uniqueness and relevance
    prompt_hash = hashlib.md5(prompt.encode('utf-8')).hexdigest()[:8]
    filename = f"img_{timestamp}_{prompt_hash}.jpg"
    return os.path.join(output_dir, filename)

def generate_image(prompt, negative_prompt=None, width=1024, height=1024, output_dir=".", model=DEFAULT_MODEL, api_key=None):
    """
    Generate an image using ModelScope API.
    """
    token = api_key or os.environ.get("MODELSCOPE_API_KEY") or DEFAULT_API_KEY
    
    if not token:
        print("Error: ModelScope API Key is required. Set MODELSCOPE_API_KEY env var or pass --api-key.")
        sys.exit(1)

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "X-ModelScope-Async-Mode": "true"
    }

    # Prepare payload
    payload = {
        "model": model,
        "prompt": prompt
    }
    
    if negative_prompt:
        payload["negative_prompt"] = negative_prompt
        
    # Note: Z-Image-Turbo might support width/height parameters differently or not at all depending on specific version,
    # but standard ModelScope text-to-image usually accepts parameters.
    # We will try to pass them in 'parameters' or top level depending on API spec.
    # For now, we put them in 'parameters' dict if the API supports it, 
    # but based on the user provided example, it's a simple JSON.
    # We will add width/height to the payload directly as common practice, 
    # if the model ignores it, it ignores it.
    payload["width"] = width
    payload["height"] = height

    print(f"🚀 Submitting task for: '{prompt}'...")
    
    try:
        response = requests.post(
            f"{BASE_URL}v1/images/generations",
            headers=headers,
            data=json.dumps(payload, ensure_ascii=False).encode('utf-8')
        )
        response.raise_for_status()
        task_data = response.json()
        task_id = task_data.get("task_id")
        
        if not task_id:
             # Synchronous return or error
             if "output_images" in task_data:
                 # Direct success
                 image_url = task_data["output_images"][0]
                 save_image(image_url, prompt, output_dir)
                 return
             else:
                 print(f"Error: No task_id returned. Response: {task_data}")
                 sys.exit(1)
                 
        print(f"✅ Task submitted (ID: {task_id}). Waiting for completion...")
        
        # Poll for status
        while True:
            status_resp = requests.get(
                f"{BASE_URL}v1/tasks/{task_id}",
                headers={**headers, "X-ModelScope-Task-Type": "image_generation"},
            )
            status_resp.raise_for_status()
            status_data = status_resp.json()
            status = status_data.get("task_status")
            
            if status == "SUCCEED":
                if "output_images" in status_data and status_data["output_images"]:
                    image_url = status_data["output_images"][0]
                    save_image(image_url, prompt, output_dir)
                    break
                else:
                     print("Error: Task succeeded but no output images found.")
                     break
            elif status == "FAILED":
                print(f"❌ Image Generation Failed: {status_data.get('message', 'Unknown error')}")
                break
            elif status in ["PENDING", "RUNNING"]:
                print(f"⏳ Status: {status}...")
                time.sleep(3)
            else:
                print(f"Unknown status: {status}")
                time.sleep(3)
                
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

def save_image(url, prompt, output_dir):
    try:
        os.makedirs(output_dir, exist_ok=True)
        print(f"Downloading image from {url}...")
        img_resp = requests.get(url)
        img_resp.raise_for_status()
        
        image = Image.open(BytesIO(img_resp.content))
        
        # Determine filename
        filepath = generate_filename(prompt, output_dir)
        
        image.save(filepath)
        print(f"✨ Image saved to: {filepath}")
        
    except Exception as e:
        print(f"Error saving image: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate images using ModelScope API")
    parser.add_argument("prompt", help="Text prompt for image generation")
    parser.add_argument("--negative-prompt", "-n", help="Negative text prompt")
    parser.add_argument("--width", type=int, default=1024, help="Image width")
    parser.add_argument("--height", type=int, default=1024, help="Image height")
    parser.add_argument("--output-dir", "-o", default=".", help="Directory to save output images")
    parser.add_argument("--model", default=DEFAULT_MODEL, help="Model ID to use")
    parser.add_argument("--api-key", help="ModelScope API Key")
    
    args = parser.parse_args()
    
    generate_image(
        prompt=args.prompt,
        negative_prompt=args.negative_prompt,
        width=args.width,
        height=args.height,
        output_dir=args.output_dir,
        model=args.model,
        api_key=args.api_key
    )
