# Union Search Skill 配置与使用指南

本文档记录了 `union-search-skill` 工具的安装、配置及使用方法。该工具旨在为 AI Agent 提供统一的跨平台搜索能力。

## 1. 项目简介

`union-search-skill` 是一个聚合搜索工具，支持通过单一接口访问多个搜索平台（如 Google, Bing, Brave, GitHub, Bilibili 等）。本项目已通过 `Makefile` 进行了封装，简化了日常操作。

**主要特性：**
- **多源聚合**：支持 20+ 平台。
- **自动降级**：Brave 搜索优先使用 API，失败自动回退到网页爬虫。
- **代理支持**：已配置本地代理以解决网络访问问题。

## 2. 快速开始

### 2.1 安装依赖

在项目根目录下运行：

```bash
make search-install
```

此命令会自动安装 Python 依赖（`requests`, `lxml`, `curl_cffi` 等）。

### 2.2 初始化配置

如果尚未创建配置，运行：

```bash
make search-setup
```

这将从 `.env.example` 复制生成 `.env` 文件。

## 3. 配置详情

配置文件位于 `union-search-skill/.env`。

### 3.1 网络代理配置 (关键)

为了确保 DuckDuckGo, Wikipedia, Brave 等海外服务可用，已配置本地代理（端口 `7897`）：

```ini
# 通用搜索引擎代理
DUCKDUCKGO_PROXY=http://127.0.0.1:7897
BRAVE_PROXY=http://127.0.0.1:7897
WIKIPEDIA_PROXY=http://127.0.0.1:7897
YAHOO_PROXY=http://127.0.0.1:7897
BING_PROXY=http://127.0.0.1:7897
ANNASARCHIVE_PROXY=http://127.0.0.1:7897
```

### 3.2 API Key 配置

目前已配置 **Brave Search API** 以获得最佳性能：

```ini
# Brave Search API Key
BRAVE_API_KEY=BSAA20wblfS8rOCp0cXdToGa6N4KmsJ
```

> **注意**：如果需要使用 B站、抖音、小红书搜索，需在 `.env` 中补充 `TIKHUB_TOKEN`。

## 4. 使用指南 (Makefile)

本项目提供了快捷的 `Makefile` 指令，无需记忆复杂的 Python 参数。

### 4.1 测试连接

检查 Brave 搜索是否正常（耗时约 1s）：

```bash
make search-test
```

### 4.2 执行搜索

**默认搜索 (Brave)**：
```bash
make search Q="AI Agent"
```

**指定平台搜索**：
```bash
# 使用 DuckDuckGo
make search Q="Python 教程" P=duckduckgo

# 使用 Wikipedia
make search Q="Large Language Model" P=wikipedia

# 使用 Yahoo
make search Q="Machine Learning" P=yahoo
```

### 4.3 常用平台代号 (P参数)

| 平台 | 代号 (P) | 状态 | 说明 |
|------|----------|------|------|
| Brave | `brave` | ✅ 极佳 | 优先走 API，速度快 |
| DuckDuckGo | `duckduckgo` | ✅ 良好 | 需代理 |
| Wikipedia | `wikipedia` | ✅ 良好 | 需代理 |
| Yahoo | `yahoo` | ✅ 良好 | 需代理 |
| Bilibili | `bilibili` | ⚠️ 需Token | 需要配置 TIKHUB_TOKEN |
| GitHub | `github` | ⚠️ 需Token | 需要配置 GITHUB_TOKEN |

## 5. 故障排查

### Q: `Connection refused` 或 `Timeout`
**原因**：代理配置错误或代理软件未开启。
**解决**：
1. 确认本地代理软件（如 Clash/V2Ray）已开启。
2. 确认 `.env` 文件中的端口号（当前为 `7897`）与代理软件一致。

### Q: `HTTP 401 Unauthorized`
**原因**：缺少 API Key。
**解决**：
- 如果是 Jina，需要 `JINA_API_KEY`。
- 如果是 B站/抖音，需要 `TIKHUB_TOKEN`。
- 检查 `.env` 文件中对应 Key 是否为空。

### Q: `Brave API 搜索失败`
**原因**：API Key 无效或额度耗尽。
**解决**：脚本会自动降级使用网页爬虫模式（速度稍慢，但仍可用）。无需人工干预。
