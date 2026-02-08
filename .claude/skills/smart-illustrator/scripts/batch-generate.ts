#!/usr/bin/env npx -y bun

/**
 * Batch Image Generation Script (ModelScope - Z-Image-Turbo)
 *
 * Generates multiple images from a JSON config file.
 * Supports the unified JSON format (same as web version).
 *
 * Usage:
 *   npx -y bun batch-generate.ts --config slides.json --output-dir ./images
 */

import { writeFile, readFile, mkdir } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { join, dirname, basename } from 'node:path';

// API endpoints
const MODELSCOPE_API_BASE = 'https://api-inference.modelscope.cn/v1';
const DEFAULT_MODELSCOPE_MODEL = 'Tongyi-MAI/Z-Image-Turbo';
const DEFAULT_MODELSCOPE_KEY = 'ms-41706221-999d-4fe6-8ee3-f3334f2069d1';

// New unified format (same as web version)
interface PictureConfig {
  id: number;
  topic: string;
  content: string;
}

interface BatchRules {
  total: number;
  one_item_one_image?: boolean;
  aspect_ratio?: string;
  do_not_merge?: boolean;
}

interface UnifiedConfig {
  instruction?: string;
  batch_rules?: BatchRules;
  fallback?: string;
  style: string;
  pictures: PictureConfig[];
}

// Legacy format (for backward compatibility)
interface LegacyIllustration {
  id: number;
  prompt: string | object;
  filename: string;
  type?: string;
  position?: string;
}

interface LegacyConfig {
  style?: {
    mode?: string;
    background?: string;
    primary?: string;
    accent?: string[];
  };
  instructions?: string;
  illustrations: LegacyIllustration[];
}

type BatchConfig = UnifiedConfig | LegacyConfig;

interface ModelScopeTaskResponse {
  task_id?: string;
  output_images?: string[];
  task_status?: 'PENDING' | 'RUNNING' | 'SUCCEED' | 'FAILED' | 'UNKNOWN';
  message?: string;
  code?: string;
}

function isUnifiedConfig(config: BatchConfig): config is UnifiedConfig {
  return 'pictures' in config && Array.isArray(config.pictures);
}

function buildPromptFromUnified(picture: PictureConfig, style: string): string {
  // Combine style + topic + content into a single prompt
  return `${style}

---

请为以下内容生成一张信息图：

**主题方向**: ${picture.topic}

**内容**:
${picture.content}`;
}

function buildPromptFromLegacy(
  illustration: LegacyIllustration,
  style?: LegacyConfig['style']
): string {
  let prompt = '';

  if (style) {
    prompt += `Style: ${style.mode || 'light'} mode, `;
    prompt += `background ${style.background || '#F8F9FA'}, `;
    prompt += `primary color ${style.primary || '#2F2B42'}, `;
    if (style.accent) {
      prompt += `accent colors ${style.accent.join(', ')}. `;
    }
  }

  if (typeof illustration.prompt === 'string') {
    prompt += illustration.prompt;
  } else {
    prompt += JSON.stringify(illustration.prompt);
  }

  return prompt;
}

async function generateImage(
  prompt: string,
  model: string,
  apiKey: string
): Promise<Buffer | null> {
  const submitUrl = `${MODELSCOPE_API_BASE}/images/generations`;

  const headers = {
    'Authorization': `Bearer ${apiKey}`,
    'Content-Type': 'application/json',
    'X-ModelScope-Async-Mode': 'true'
  };

  const payload = {
    model: model,
    prompt: prompt,
    width: 1024,
    height: 1024
  };

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
    if (submitData.output_images && submitData.output_images.length > 0) {
      return await downloadImageBuffer(submitData.output_images[0]);
    }
    throw new Error(`ModelScope Error: No task_id returned.`);
  }

  // 2. Poll Status
  const pollUrl = `${MODELSCOPE_API_BASE}/tasks/${taskId}`;
  const pollHeaders = {
    ...headers,
    'X-ModelScope-Task-Type': 'image_generation'
  };

  let attempts = 0;
  const maxAttempts = 60;

  while (attempts < maxAttempts) {
    attempts++;
    await new Promise(resolve => setTimeout(resolve, 3000)); // Wait 3s

    const pollResp = await fetch(pollUrl, { headers: pollHeaders });
    
    if (!pollResp.ok) continue;

    const pollData = await pollResp.json() as ModelScopeTaskResponse;
    const status = pollData.task_status;

    if (status === 'SUCCEED') {
      if (pollData.output_images && pollData.output_images.length > 0) {
        return await downloadImageBuffer(pollData.output_images[0]);
      } else {
        throw new Error('Task succeeded but no output images found.');
      }
    } else if (status === 'FAILED') {
      throw new Error(`Image Generation Failed: ${pollData.message || 'Unknown error'}`);
    }
    // Continue polling
  }

  throw new Error('Timeout waiting for image generation');
}

async function downloadImageBuffer(url: string): Promise<Buffer> {
  const resp = await fetch(url);
  if (!resp.ok) {
    throw new Error(`Failed to download image: ${resp.statusText}`);
  }
  const arrayBuffer = await resp.arrayBuffer();
  return Buffer.from(arrayBuffer);
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function printUsage(): never {
  console.log(`
Batch Image Generation Script (ModelScope)

Usage:
  npx -y bun batch-generate.ts --config slides.json --output-dir ./images

Options:
  -c, --config <path>       JSON config file
  -o, --output-dir <path>   Output directory (default: ./illustrations)
  -m, --model <model>       Model to use (default: Tongyi-MAI/Z-Image-Turbo)
  -d, --delay <ms>          Delay between requests in ms (default: 2000)
  -p, --prefix <text>       Filename prefix
  -r, --regenerate <ids>    Regenerate specific images (e.g., "3" or "3,5,7")
  -f, --force               Force regenerate all images
  -h, --help                Show this help

Environment:
  MODELSCOPE_API_KEY        Optional. Uses default free key if not set.
`);
  process.exit(0);
}

async function main() {
  const args = process.argv.slice(2);

  let configPath: string | null = null;
  let outputDir = './illustrations';
  let model = DEFAULT_MODELSCOPE_MODEL;
  let delay = 2000;
  let prefix: string | null = null;
  let forceRegenerate = false;
  let regenerateIds: Set<number> | null = null;

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    switch (arg) {
      case '-h':
      case '--help':
        printUsage();
        break;
      case '-c':
      case '--config':
        configPath = args[++i];
        break;
      case '-o':
      case '--output-dir':
        outputDir = args[++i];
        break;
      case '-m':
      case '--model':
        model = args[++i];
        break;
      case '-d':
      case '--delay':
        delay = parseInt(args[++i], 10);
        break;
      case '-p':
      case '--prefix':
        prefix = args[++i];
        break;
      case '-f':
      case '--force':
        forceRegenerate = true;
        break;
      case '-r':
      case '--regenerate':
        regenerateIds = new Set(
          args[++i].split(',').map(id => parseInt(id.trim(), 10))
        );
        break;
    }
  }

  const apiKey = process.env.MODELSCOPE_API_KEY || DEFAULT_MODELSCOPE_KEY;

  if (!configPath) {
    console.error('Error: --config is required');
    process.exit(1);
  }

  const configContent = await readFile(configPath, 'utf-8');
  const config: BatchConfig = JSON.parse(configContent);

  // Auto-detect prefix from config filename if not specified
  if (!prefix) {
    prefix = basename(configPath, '.json').replace(/-slides$/, '');
  }

  await mkdir(outputDir, { recursive: true });

  // Handle unified format vs legacy format
  if (isUnifiedConfig(config)) {
    // Unified format (new)
    const total = config.pictures.length;
    let success = 0;
    let failed = 0;
    let skipped = 0;

    console.log(`\nBatch Image Generation (Unified Format)`);
    console.log(`=======================================`);
    console.log(`Model: ${model}`);
    console.log(`Total: ${total} images`);
    console.log(`Prefix: ${prefix}`);
    console.log(`Output: ${outputDir}`);
    console.log(`Delay: ${delay}ms between requests`);
    if (forceRegenerate) {
      console.log(`Mode: Force regenerate all`);
    } else if (regenerateIds) {
      console.log(`Mode: Regenerate specific IDs: ${[...regenerateIds].join(', ')}`);
    } else {
      console.log(`Mode: Resume (skip existing)`);
    }
    console.log();

    let needsDelay = false;

    for (const picture of config.pictures) {
      const filename = `${prefix}-${String(picture.id).padStart(2, '0')}.png`;
      const outputPath = join(outputDir, filename);

      // Check if we should skip this image
      const fileExists = existsSync(outputPath);
      const shouldRegenerate = regenerateIds?.has(picture.id);
      const shouldSkip = fileExists && !forceRegenerate && !shouldRegenerate;

      if (shouldSkip) {
        console.log(`[${picture.id}/${total}] Skipping: ${filename} (already exists)`);
        skipped++;
        continue;
      }

      // Add delay before generation (except for first image)
      if (needsDelay) {
        console.log(`  Waiting ${delay}ms...`);
        await sleep(delay);
      }

      console.log(`[${picture.id}/${total}] Generating: ${filename}`);
      console.log(`  Topic: ${picture.topic}`);
      if (shouldRegenerate) {
        console.log(`  (Regenerating as requested)`);
      }

      try {
        const prompt = buildPromptFromUnified(picture, config.style);
        const imageBuffer = await generateImage(prompt, model, apiKey);

        if (imageBuffer) {
          await mkdir(dirname(outputPath), { recursive: true });
          await writeFile(outputPath, imageBuffer);
          console.log(`  ✓ Saved (${(imageBuffer.length / 1024).toFixed(1)} KB)`);
          success++;
          needsDelay = true;
        } else {
          console.log(`  ✗ No image generated`);
          failed++;
          needsDelay = true;
        }
      } catch (error) {
        console.log(`  ✗ Error: ${error instanceof Error ? error.message : error}`);
        failed++;
        needsDelay = true;
      }
    }

    console.log(`\n=======================================`);
    if (skipped > 0) {
      console.log(`Complete: ${success} generated, ${skipped} skipped, ${failed} failed`);
    } else {
      console.log(`Complete: ${success}/${total} succeeded, ${failed} failed`);
    }
    console.log(`Output directory: ${outputDir}`);

  } else {
    // Legacy format (backward compatibility)
    const legacyConfig = config as LegacyConfig;

    if (!legacyConfig.illustrations || legacyConfig.illustrations.length === 0) {
      console.error('Error: No illustrations in config');
      process.exit(1);
    }

    const total = legacyConfig.illustrations.length;
    let success = 0;
    let failed = 0;
    let skipped = 0;

    console.log(`\nBatch Image Generation (Legacy Format)`);
    console.log(`======================================`);
    console.log(`Model: ${model}`);
    console.log(`Total: ${total} images`);
    console.log(`Output: ${outputDir}`);
    if (forceRegenerate) {
      console.log(`Mode: Force regenerate all`);
    } else if (regenerateIds) {
      console.log(`Mode: Regenerate specific IDs: ${[...regenerateIds].join(', ')}`);
    } else {
      console.log(`Mode: Resume (skip existing)`);
    }
    console.log();

    let needsDelay = false;

    for (const illustration of legacyConfig.illustrations) {
      const outputPath = join(outputDir, illustration.filename);

      // Check if we should skip this image
      const fileExists = existsSync(outputPath);
      const shouldRegenerate = regenerateIds?.has(illustration.id);
      const shouldSkip = fileExists && !forceRegenerate && !shouldRegenerate;

      if (shouldSkip) {
        console.log(`[${illustration.id}/${total}] Skipping: ${illustration.filename} (already exists)`);
        skipped++;
        continue;
      }

      // Add delay before generation (except for first image)
      if (needsDelay) {
        await sleep(delay);
      }

      console.log(`[${illustration.id}/${total}] Generating: ${illustration.filename}`);
      if (shouldRegenerate) {
        console.log(`  (Regenerating as requested)`);
      }

      try {
        const prompt = buildPromptFromLegacy(illustration, legacyConfig.style);
        const imageBuffer = await generateImage(prompt, model, apiKey);

        if (imageBuffer) {
          await mkdir(dirname(outputPath), { recursive: true });
          await writeFile(outputPath, imageBuffer);
          console.log(`  ✓ Saved (${(imageBuffer.length / 1024).toFixed(1)} KB)`);
          success++;
          needsDelay = true;
        } else {
          console.log(`  ✗ No image generated`);
          failed++;
          needsDelay = true;
        }
      } catch (error) {
        console.log(`  ✗ Error: ${error instanceof Error ? error.message : error}`);
        failed++;
        needsDelay = true;
      }
    }

    console.log(`\n======================================`);
    if (skipped > 0) {
      console.log(`Complete: ${success} generated, ${skipped} skipped, ${failed} failed`);
    } else {
      console.log(`Complete: ${success}/${total} succeeded, ${failed} failed`);
    }
    console.log(`Output directory: ${outputDir}`);
  }
}

main().catch(console.error);
