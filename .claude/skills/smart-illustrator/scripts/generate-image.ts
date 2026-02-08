#!/usr/bin/env npx -y bun

/**
 * Image Generation Script (ModelScope - Z-Image-Turbo)
 *
 * Usage:
 *   npx -y bun ~/.claude/skills/smart-illustrator/scripts/generate-image.ts --prompt "A cute cat" --output cat.png
 *   npx -y bun ~/.claude/skills/smart-illustrator/scripts/generate-image.ts --prompt-file prompt.md --output image.png
 *
 * Environment:
 *   MODELSCOPE_API_KEY - ModelScope API key (optional, has default)
 *
 * Models:
 *   Tongyi-MAI/Z-Image-Turbo (default)
 */

import { writeFile, readFile, mkdir } from 'node:fs/promises';
import { dirname, extname, isAbsolute, resolve } from 'node:path';
import { loadConfig, saveConfig, mergeConfig, type Config } from './config.js';
import { analyzeCoverImage, saveLearning, getLearningsPrompt, loadLearnings } from './cover-learner.js';

// API endpoints
const MODELSCOPE_API_BASE = 'https://api-inference.modelscope.cn/v1';
const DEFAULT_MODELSCOPE_MODEL = 'Tongyi-MAI/Z-Image-Turbo';
// Default key from image-generator skill
const DEFAULT_MODELSCOPE_KEY = 'ms-41706221-999d-4fe6-8ee3-f3334f2069d1';

// Supported aspect ratios
type AspectRatio = '1:1' | '2:3' | '3:2' | '3:4' | '4:3' | '4:5' | '5:4' | '9:16' | '16:9' | '21:9';

interface ModelScopeTaskResponse {
  task_id?: string;
  output_images?: string[];
  task_status?: 'PENDING' | 'RUNNING' | 'SUCCEED' | 'FAILED' | 'UNKNOWN';
  message?: string;
  code?: string;
}

/**
 * Generate image using ModelScope API
 */
async function generateImageModelScope(
  prompt: string,
  model: string,
  apiKey: string,
  width: number = 1024,
  height: number = 1024
): Promise<{ imageData: Buffer; mimeType: string } | null> {
  const submitUrl = `${MODELSCOPE_API_BASE}/images/generations`;

  const headers = {
    'Authorization': `Bearer ${apiKey}`,
    'Content-Type': 'application/json',
    'X-ModelScope-Async-Mode': 'true'
  };

  const payload = {
    model: model,
    prompt: prompt,
    width: width,
    height: height
  };

  console.log(`🚀 Submitting task to ModelScope (${model})...`);

  // 1. Submit Task
  const submitResp = await fetch(submitUrl, {
    method: 'POST',
    headers,
    body: JSON.stringify(payload)
  });

  if (!submitResp.ok) {
    const errorText = await submitResp.text();
    throw new Error(`ModelScope Submit Error: ${submitResp.status} ${submitResp.statusText} - ${errorText}`);
  }

  const submitData = await submitResp.json() as ModelScopeTaskResponse;
  const taskId = submitData.task_id;

  if (!taskId) {
    // Check if immediate result
    if (submitData.output_images && submitData.output_images.length > 0) {
      return await downloadImage(submitData.output_images[0]);
    }
    throw new Error(`ModelScope Error: No task_id returned. Response: ${JSON.stringify(submitData)}`);
  }

  console.log(`✅ Task submitted (ID: ${taskId}). Waiting for completion...`);

  // 2. Poll Status
  const pollUrl = `${MODELSCOPE_API_BASE}/tasks/${taskId}`;
  const pollHeaders = {
    ...headers,
    'X-ModelScope-Task-Type': 'image_generation'
  };

  let attempts = 0;
  const maxAttempts = 60; // 3 minutes max (3s interval)

  while (attempts < maxAttempts) {
    attempts++;
    await new Promise(resolve => setTimeout(resolve, 3000)); // Wait 3s

    const pollResp = await fetch(pollUrl, { headers: pollHeaders });
    
    if (!pollResp.ok) {
      console.warn(`Polling warning: ${pollResp.status} ${pollResp.statusText}`);
      continue;
    }

    const pollData = await pollResp.json() as ModelScopeTaskResponse;
    const status = pollData.task_status;

    if (status === 'SUCCEED') {
      if (pollData.output_images && pollData.output_images.length > 0) {
        console.log('✨ Generation succeeded!');
        return await downloadImage(pollData.output_images[0]);
      } else {
        throw new Error('Task succeeded but no output images found.');
      }
    } else if (status === 'FAILED') {
      throw new Error(`Image Generation Failed: ${pollData.message || 'Unknown error'}`);
    } else {
      process.stdout.write(`⏳ Status: ${status}...\r`);
    }
  }

  throw new Error('Timeout waiting for image generation');
}

async function downloadImage(url: string): Promise<{ imageData: Buffer; mimeType: string }> {
  console.log(`Downloading image from ${url}...`);
  const resp = await fetch(url);
  if (!resp.ok) {
    throw new Error(`Failed to download image: ${resp.statusText}`);
  }
  const arrayBuffer = await resp.arrayBuffer();
  const buffer = Buffer.from(arrayBuffer);
  
  // Detect mime type from url or content
  let mimeType = 'image/jpeg'; // Default
  if (url.endsWith('.png')) mimeType = 'image/png';
  if (url.endsWith('.webp')) mimeType = 'image/webp';
  
  return { imageData: buffer, mimeType };
}

function printUsage(): never {
  console.log(`
Image Generation Script (ModelScope - Z-Image-Turbo)

Usage:
  npx -y bun generate-image.ts --prompt "description" --output image.png
  npx -y bun generate-image.ts --prompt-file prompt.md --output image.png

Options:
  -p, --prompt <text>       Image description
  -f, --prompt-file <path>  Read prompt from file
  -o, --output <path>       Output image path (default: generated.jpg)
  -m, --model <model>       Model ID (default: Tongyi-MAI/Z-Image-Turbo)
  --width <int>             Image width (default: 1024)
  --height <int>            Image height (default: 1024)
  -a, --aspect-ratio <ratio> Preset aspect ratio (overrides width/height)
                            (1:1, 3:4, 4:3, 9:16, 16:9)
  -h, --help                Show this help

Advanced:
  --save-config             Save current settings to project config
  --no-config               Ignore config files

Environment Variables:
  MODELSCOPE_API_KEY        API key (optional, uses default free key)
`);
  process.exit(0);
}

// Helper to calculate dimensions from aspect ratio
function getDimensions(ratio: AspectRatio, baseSize: number = 1024): { width: number, height: number } {
  const [w, h] = ratio.split(':').map(Number);
  if (!w || !h) return { width: baseSize, height: baseSize };
  
  // Scale so the largest dimension is baseSize (or close to it)
  // For Z-Image-Turbo, 1024x1024 is standard.
  // 16:9 -> 1280x720 approx
  // 9:16 -> 720x1280 approx
  
  if (w > h) {
    return { width: 1280, height: Math.round(1280 * (h/w)) };
  } else if (h > w) {
    return { width: Math.round(1280 * (w/h)), height: 1280 };
  } else {
    return { width: 1024, height: 1024 };
  }
}

async function main() {
  const args = process.argv.slice(2);

  let prompt: string | null = null;
  let promptFile: string | null = null;
  let output = 'generated.jpg';
  let model: string = DEFAULT_MODELSCOPE_MODEL;
  let width = 1024;
  let height = 1024;
  let aspectRatio: AspectRatio | undefined;
  
  // Config flags
  let shouldSaveConfig = false;
  let saveConfigGlobal = false;
  let noConfig = false;
  
  // Legacy/Ignored flags (kept for compatibility to avoid crashing)
  let candidates = 1;
  let refPaths: string[] = [];

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    switch (arg) {
      case '-h':
      case '--help':
        printUsage();
        break;
      case '-p':
      case '--prompt':
        prompt = args[++i];
        break;
      case '-f':
      case '--prompt-file':
        promptFile = args[++i];
        break;
      case '-o':
      case '--output':
        output = args[++i];
        break;
      case '-m':
      case '--model':
        model = args[++i];
        break;
      case '--width':
        width = parseInt(args[++i], 10);
        break;
      case '--height':
        height = parseInt(args[++i], 10);
        break;
      case '--aspect-ratio':
      case '-a':
        aspectRatio = args[++i] as AspectRatio;
        break;
      case '--save-config':
        shouldSaveConfig = true;
        break;
      case '--no-config':
        noConfig = true;
        break;
      // Legacy flags - consume arguments but ignore
      case '-c':
      case '--candidates':
        i++; 
        break;
      case '-r':
      case '--ref':
        i++;
        break;
      case '--provider':
      case '--size':
      case '--ref-weight':
      case '--learn-cover':
      case '--learn-note':
        i++;
        break;
    }
  }

  // Load config
  let loadedConfig: Config = {};
  if (!noConfig) {
    try {
      loadedConfig = loadConfig(process.cwd());
    } catch (error) {
      // Ignore config errors
    }
  }

  // Determine API Key
  const apiKey = process.env.MODELSCOPE_API_KEY || DEFAULT_MODELSCOPE_KEY;

  if (promptFile) {
    prompt = await readFile(promptFile, 'utf-8');
  }

  if (!prompt) {
    console.error('Error: --prompt or --prompt-file is required');
    process.exit(1);
  }

  // Apply aspect ratio if specified
  if (aspectRatio) {
    const dims = getDimensions(aspectRatio);
    width = dims.width;
    height = dims.height;
    console.log(`Applying aspect ratio ${aspectRatio} -> ${width}x${height}`);
  }

  console.log(`Model: ${model}`);
  console.log(`Output: ${output}`);

  try {
    const result = await generateImageModelScope(prompt, model, apiKey, width, height);
    
    if (result) {
      await writeFile(output, result.imageData);
      console.log(`\n✓ Saved image to ${output}`);
    } else {
      console.error('Failed to generate image (no result)');
      process.exit(1);
    }
  } catch (error: any) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  }
}

main().catch(console.error);
