---
name: "wechat-draft-sync"
description: "将本地 Markdown 文档同步到微信公众号草稿箱。当用户要求发布或同步文章到微信公众号时调用。"
---

# 微信公众号草稿同步 (WeChat Draft Sync)

本 Skill 提供了一个 TS 脚本 `draft-sync.ts`，用于将 Markdown 文档同步到微信公众号后台草稿箱。

## 功能

1.  **解析 Markdown**: 提取 frontmatter (标题、作者、摘要、封面图) 和正文。
2.  **上传图片**: 自动识别文档中的图片，上传到微信服务器，并替换链接。
3.  **上传封面**: 上传 frontmatter 中指定的封面图。
4.  **生成草稿**: 将处理后的 Markdown 转换为 HTML 并创建草稿。

## 前置条件

1.  **环境**: 需要安装 `bun`。
2.  **配置**: 需要在 `.claude/skills/wechat-draft-sync/scripts/.env` 文件中配置 `WECHAT_APP_ID` 和 `WECHAT_APP_SECRET`。
    *   你可以通过复制 `.env.example` 来创建 `.env`。

## 用法 (Usage)

### 同步文档

运行脚本并指定 Markdown 文件路径。

- **命令**: `bun run .claude/skills/wechat-draft-sync/scripts/draft-sync.ts <path-to-markdown-file>`
- **示例**: `bun run .claude/skills/wechat-draft-sync/scripts/draft-sync.ts docs/my-article.md`

## Markdown 格式要求

建议在 Markdown 文件开头添加 Frontmatter：

```markdown
---
title: "文章标题"
author: "作者名"
digest: "文章摘要"
cover_image: "./images/cover.jpg"
content_source_url: "原文链接(可选)"
---
```

如果不提供 title，将使用文件名。
如果不提供 cover_image，可能会导致草稿创建失败（取决于微信接口要求，通常建议提供）。

## 安装依赖

首次使用前，请确保依赖已安装：

```bash
cd .claude/skills/wechat-draft-sync/scripts && bun install
```
