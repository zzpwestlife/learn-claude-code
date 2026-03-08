# 技能安装过程文档

## 安装环境
- **操作系统**: macOS
- **Node.js版本**: v25.5.0
- **npm版本**: 11.8.0
- **安装目录**: `/Users/joeyzou/Code/OpenSource/learn-claude-code`

## 安装工具列表

### 1. Agent Reach
- **安装命令**: `npx skills add Panniantong/Agent-Reach`
- **安装状态**: ✅ 成功
- **安装位置**: `~/.agents/skills/agent-reach`
- **功能描述**: 给 AI Agent 一键装上互联网能力，支持搜索、阅读和交互 13+ 平台
- **支持平台**: Twitter/X、Reddit、YouTube、GitHub、B站、小红书、抖音、微信公众号、LinkedIn、Boss直聘、RSS、Exa 网络搜索等
- **注意事项**: 安全风险评估为中等风险，使用时需注意权限

### 2. Defuddle
- **安装命令**: `npx skills add joeseesun/defuddle-skill`
- **安装状态**: ✅ 成功
- **安装位置**: `~/.agents/skills/defuddle`
- **功能描述**: 提取网页干净内容，去除广告/侧边栏，输出Markdown正文+元数据
- **注意事项**: 自动安装了 find-skills 工具作为辅助

### 3. YouTube 全站搜索+下载
- **安装命令**: `npx skills add joeseesun/yt-search-download`
- **安装状态**: ✅ 成功
- **安装位置**: `~/.agents/skills/yt-search-download`
- **功能描述**: YouTube 视频搜索、下载视频、下载字幕工具
- **核心能力**: 
  - 全站关键词搜索
  - 频道浏览
  - 按时间/播放量/相关度排序
  - 下载视频
  - 提取音频（MP3）
  - 下载字幕（中英文）
  - 查看视频详情

### 4. baoyu-skills
- **安装命令**: `npx skills add jimliu/baoyu-skills --yes`
- **安装状态**: ✅ 成功
- **安装位置**: `~/Code/OpenSource/learn-claude-code/.agents/skills/`
- **包含技能**: 18个技能，涵盖以下类别
  - Ai Generation Skills: baoyu-danger-gemini-web, baoyu-image-gen
  - Content Skills: baoyu-article-illustrator, baoyu-comic, baoyu-cover-image, baoyu-infographic, baoyu-post-to-wechat, baoyu-post-to-weibo, baoyu-post-to-x, baoyu-slide-deck, baoyu-xhs-images
  - Utility Skills: baoyu-compress-image, baoyu-danger-x-to-markdown, baoyu-format-markdown, baoyu-markdown-to-html, baoyu-translate, baoyu-url-to-markdown
  - General: release-skills
- **注意事项**: 使用 `--yes` 标志进行非交互式安装

### 5. knowledge-site-creator
- **安装命令**: `npx skills add joeseesun/knowledge-site-creator --yes`
- **安装状态**: ✅ 成功
- **安装位置**: `~/Code/OpenSource/learn-claude-code/.agents/skills/knowledge-site-creator`
- **功能描述**: 一句话生成任何领域的知识学习网站，AI自动理解主题、创作内容、生成页面、部署上线

## 安装总结

| 工具名称 | 安装状态 | 安装命令 | 主要功能 |
|---------|---------|---------|--------|
| Agent Reach | ✅ 成功 | `npx skills add Panniantong/Agent-Reach` | 零API成本让AI访问互联网 |
| Defuddle | ✅ 成功 | `npx skills add joeseesun/defuddle-skill` | 提取网页干净内容 |
| YouTube 全站搜索+下载 | ✅ 成功 | `npx skills add joeseesun/yt-search-download` | 视频搜索、下载、字幕提取 |
| baoyu-skills | ✅ 成功 | `npx skills add jimliu/baoyu-skills --yes` | 内容创作、图像处理、多平台发布 |
| knowledge-site-creator | ✅ 成功 | `npx skills add joeseesun/knowledge-site-creator --yes` | 自动生成知识学习网站 |

## 遇到的问题及解决方案

1. **Agent Reach 初始安装失败**
   - 问题: 仓库路径不正确，导致 403 错误
   - 解决: 使用正确的 GitHub 仓库路径 `Panniantong/Agent-Reach` 安装成功

2. **baoyu-skills 安装需要交互**
   - 问题: 安装过程中需要选择要安装的技能
   - 解决: 使用 `--yes` 标志进行非交互式安装

3. **Skills 命令依赖**
   - 问题: 首次使用 `npx skills` 命令时需要安装 skills 包
   - 解决: 系统会自动提示安装，输入 `y` 确认即可

## 后续步骤

1. **配置环境**
   - 对于 YouTube 工具，需要配置 YouTube API Key
   - 对于需要特定权限的工具，需要配置相应的认证信息

2. **测试功能**
   - 测试已安装工具的基本功能
   - 验证工具是否能正常工作

3. **文档更新**
   - 如有新的工具安装或问题解决，及时更新此文档

## 注意事项

- 部分工具需要网络连接才能正常使用
- 部分工具可能需要特定的 API Key 或认证信息
- 安装的工具会获得完整的 agent 权限，请谨慎使用
- 定期检查工具更新，确保功能正常

## 应用示例

### 1. Agent Reach
- **示例1: 搜索推特内容**
  ```
  帮我搜索推特上关于 AI 大模型的最新讨论
  ```
- **示例2: 提取 YouTube 视频字幕**
  ```
  帮我提取这个 YouTube 视频的字幕：https://www.youtube.com/watch?v=example
  ```
- **示例3: 阅读小红书内容**
  ```
  帮我看看小红书上关于旅行攻略的热门帖子
  ```

### 2. Defuddle
- **示例1: 提取网页内容**
  ```
  帮我提取这个网页的干净内容：https://example.com/article
  ```
- **示例2: 转换为 Markdown**
  ```
  帮我把这个网页转换为 Markdown 格式：https://example.com/blog
  ```

### 3. YouTube 全站搜索+下载
- **示例1: 搜索视频**
  ```
  帮我搜索关于 Python 编程的最新教程视频
  ```
- **示例2: 下载视频**
  ```
  帮我下载这个 YouTube 视频，选择高清画质：https://www.youtube.com/watch?v=example
  ```
- **示例3: 提取字幕**
  ```
  帮我提取这个视频的中文字幕：https://www.youtube.com/watch?v=example
  ```

### 4. baoyu-skills
- **示例1: 生成文章封面**
  ```
  帮我为这篇关于 AI 发展的文章生成一个专业的封面图
  ```
- **示例2: 翻译文章**
  ```
  帮我把这篇英文文章翻译成中文：[文章内容]
  ```
- **示例3: 发布到社交媒体**
  ```
  帮我把这篇文章发布到 X 平台：[文章内容]
  ```

### 5. knowledge-site-creator
- **示例1: 生成学习网站**
  ```
  帮我生成一个关于机器学习的学习网站，包含基础概念、算法介绍和实践教程
  ```
- **示例2: 生成技术文档网站**
  ```
  帮我为这个项目生成一个技术文档网站：[项目描述]
  ```