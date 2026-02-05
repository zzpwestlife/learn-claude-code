# Project
AI 原生开发工作流实战 (极客时间课程) 学习笔记与实战演练项目. 
核心内容为 Markdown 格式的课程文档及相关代码示例. 

# Stack
- Documentation: Markdown
- Diagrams: Mermaid
- Language: Chinese (Simplified) for content, English for technical terms

# Structure
- `/`: 根目录, 包含所有课程章节 Markdown 文件 (00-23) 及 README.md
- `images/`: 存放课程相关的图片资源

# Rules
- **File Naming**: 保持原有的 numbered naming convention (e.g., `01｜Title...md`). 不要随意重命名现有文件. 
- **Content**: 
  - 所有新增或修改的内容必须使用中文 (简体) . 
  - 专有名词 (如 Claude Code, MCP, Context) 保持英文. 
- **Mermaid**:
  - 编写 Mermaid 图表时, **必须**给节点文本加上双引号, 以避免解析错误. 
  - Example: `A["节点文本: 包含特殊符号"]`
- **Editing**:
  - 修改长文档时, 优先使用 `search_replace` 或 `edit_file`, 避免全量重写导致 token 浪费. 
  - 保持 Markdown 格式的整洁 (空行、标题层级) . 
- **Anti-Hallucination & Safety** (From Best Practices):
  - **Ambiguity Handling**: 若用户指令存在歧义 (如"跟上面一样") , 必须先明确具体方案再执行, 严禁猜测. 
  - **Batch Operations**: 对于涉及大量文件 (>5个) 的修改, **必须**先在一个文件中验证方案 (Prototype) , 确认无误后再批量执行. 
  - **Precision**: 在理解需求时, 优先匹配具体的文件名、变量名和代码符号. 

# Output
- 回复语言: 中文. 
- 风格: 简洁、专业、工程化. 
- 引用: 提及课程内容时, 尽量使用文件名编号 (如 "第06课") . 
