---
name: image-generator
description: Generate images from text prompts using ModelScope API (Z-Image-Turbo). Invoke when user wants to create/generate/draw an image from a description.
tools:
  - generate_image
---

# Image Generator

This skill generates images from text descriptions using the ModelScope API (default model: Tongyi-MAI/Z-Image-Turbo).

## Usage

Provide a text prompt describing the image you want to generate. You can optionally specify negative prompts, image dimensions, and output location.

## Implementation

This skill uses a Python script `scripts/generator.py` to interact with the ModelScope API.

### Dependencies

- requests
- Pillow

### Command

```bash
python3 .claude/skills/image-generator/scripts/generator.py "your prompt here" [options]
```

### Options

- `prompt`: The text description of the image (Required)
- `--negative-prompt`, `-n`: Things to exclude from the image
- `--width`: Image width (default: 1024)
- `--height`: Image height (default: 1024)
- `--output-dir`, `-o`: Directory to save the image (default: current directory)
- `--model`: ModelScope model ID (default: Tongyi-MAI/Z-Image-Turbo)
- `--api-key`: API Key (optional, defaults to hardcoded key or env var)
