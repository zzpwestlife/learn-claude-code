---
name: wechat-article-fetcher
description: Fetch WeChat official account articles, saving them as Markdown and HTML with local images. Invoke when user wants to download/archive/read a WeChat article from a URL.
tools:
  - fetch_wechat_article
---

# WeChat Article Fetcher

This skill downloads a WeChat official account article from a given URL, extracts the content (including images), and saves it as both Markdown and HTML files. Images are downloaded locally to ensure the content is self-contained.

## Usage

Provide the URL of the WeChat article. Optionally, specify an output directory.

## Implementation

This skill uses a Python script `scripts/fetcher.py` to perform the extraction.

### Dependencies

- requests
- beautifulsoup4
- markdownify

### Command

```bash
python3 .claude/skills/wechat-article-fetcher/scripts/fetcher.py <url> [output_dir]
```
