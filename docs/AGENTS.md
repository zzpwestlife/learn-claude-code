# AI 原生开发工作流实战课程文档

**用途**: 极客时间课程全套文档与资源

## 结构

```
docs/
├── *.md                          # 24章节课程 (00-23)
├── constitution/                 # 宪法语言附录
│   ├── go_annex.md
│   ├── php_annex.md
│   └── python_annex.md
├── templates/                    # 模板目录
│   └── EXAMPLE_DEVELOPER_GUIDE.md
├── AI 原生开发工作流实战/         # 课程章节
└── *.md                          # 贡献指南、评估报告等
```

## WHERE TO LOOK

| 需求 | 路径 |
|------|------|
| 宪法核心原则 | `constitution.md` (根目录) |
| Go 语言规范 | `docs/constitution/go_annex.md` |
| PHP 语言规范 | `docs/constitution/php_annex.md` |
| Python 语言规范 | `docs/constitution/python_annex.md` |
| 课程章节 | `docs/AI 原生开发工作流实战/` |

## 文档链

```
constitution.md (核心)
├── docs/constitution/go_annex.md
├── docs/constitution/php_annex.md
└── docs/constitution/python_annex.md
```

## ANTI-PATTERNS

- ❌ 禁止修改已发布的课程章节编号
- ❌ 文档中禁止使用未定义的缩写
- ❌ 禁止跳过文档的格式校验

## 规范

1. **章节编号**: 严格按 00-23 顺序
2. **中文排版**: 遵循 constitution.md 第六条
3. **交叉引用**: 使用相对路径引用同级文档
