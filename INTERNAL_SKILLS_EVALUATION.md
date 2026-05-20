# 内部 Skill Hub 上架评估报告

## 1. 评估背景
基于公司内部 Skill Hub（[futu.feishu.cn/wiki/OZvPwsOgFiDzKhkO9P1cvVn0nUd](https://futu.feishu.cn/wiki/OZvPwsOgFiDzKhkO9P1cvVn0nUd)）的建设需求，为了盘活内部技能资产、降低研发与接入成本、提升 AI/业务能力迭代效率，本次对本地（`.claude/skills/`）的现有 Skill 进行了全面扫描与评估。

**核心原则：** 提取具有内部业务价值、定制化程度高的技能；排除在 GitHub 上公开可查的通用型开发技能。

---

## 2. 排除的开源通用技能
以下技能属于开源社区/官方标准示例中广泛存在的通用流程技能，不建议占用内部 Skill Hub 资源，或者可以作为基础镜像默认内置：

- `brainstorming`
- `code-review`
- `dispatching-parallel-agents`
- `executing-plans`
- `finishing-a-development-branch`
- `receiving-code-review`
- `requesting-code-review`
- `subagent-driven-development`
- `systematic-debugging`
- `test-driven-development`
- `using-git-worktrees`
- `using-superpowers`
- `verification-before-completion`
- `writing-plans`
- `writing-skills`

---

## 3. 推荐上架的内部/定制化技能

### 3.1 飞书生态集成类
**Skill Name:** `lark-doc-copywriting`
- **一句话功能:** 飞书文档中文文案排版与标点清理工具。
- **内部价值:** 极高。深度结合飞书 API 与内部文档规范，可大幅提升文档编写效率。
- **建议标签:** `Lark`, `文档`, `自动化`, `飞书`
- **上架建议:** 
  - 命名空间：建议发布在**团队空间**（如 `team-efficiency`）。
  - 需要确保 `metadata.assets` 中的 Python 脚本（`lark_copywriting.py`, `show_summary.py`）能与技能打包（Zip包导入或 Git 仓库绑定）一同发布。

### 3.2 基础架构接入与测试效能类
**Skill Name:** `kafka-frpc`
- **一句话功能:** 面向 FRPC Go 项目的 Kafka 接入向导与配置速查工具。
- **内部价值:** 高。深度绑定公司内部 `frpc` 基建、多地区 Kafka 集群配置、接入约束与排障经验，可显著降低接入成本并减少配置错误。
- **建议标签:** `FRPC`, `Kafka`, `接入向导`, `配置`, `内部基建`
- **上架建议:** 
  - 建议由 AI 平台、研发效能或基础架构团队发布至**团队空间**。
  - 需要确保技能附带的参考资料（如 `reference/kafka-frpc-integration-guide.md`）与 `test-prompts.json` 一同打包发布。

**Skill Name:** `add-frpc-tests`
- **一句话功能:** 面向 FRPC Go 代码库的定制化补单测与覆盖率提升工具。
- **内部价值:** 高。深度绑定公司内部 `frpc` 测试基建、Mock 体系、`application.Run` 约束与覆盖率治理流程，可显著降低补测成本并提升测试一致性。
- **建议标签:** `FRPC`, `Golang`, `测试`, `覆盖率`, `内部基建`
- **上架建议:** 
  - 建议由 AI 平台、研发效能或测试基础设施团队发布至**团队空间**。
  - 需要确保技能目录中的 `references/` 资料与 `test-prompts.json` 一同打包发布，避免 mock 指南缺失影响使用效果。

### 3.3 AI 与工程流程质量类
**Skill Name:** `darwin-skill`
- **一句话功能:** 借鉴 Karpathy autoresearch 的自主实验循环，对 Agent Skills 进行持续打分与优化。
- **内部价值:** 高。可作为公司内部维护高质量 Skill 生态的基础设施工具。
- **建议标签:** `AI`, `Agent`, `评估`, `工具`
- **上架建议:** 适合由 AI 平台团队（如 `team-ai-infra`）发布为官方维护的 Skill。

**Skill Name:** `design-first`
- **一句话功能:** 强制推行“先设计再实施”的架构方案评估铁律流程。
- **内部价值:** 高。有助于规范公司内部 AI 辅助编程的研发流程，避免直接写代码带来的架构混乱。
- **建议标签:** `流程`, `研发规范`, `架构`
- **上架建议:** 建议作为研发团队的标准流程规范，上架至内部公开市场。

**Skill Name:** `neat-freak`
- **一句话功能:** 会话结束时的文档与内存同步收尾工具。
- **内部价值:** 中等。有助于保持本地代码库与 AI 上下文文档的一致性。
- **建议标签:** `流程`, `文档管理`
- **上架建议:** 适合作为个人或团队的基础辅助工具，全员公开可见。

### 3.4 文本与沟通优化类
**Skill Name:** `humanizer`
- **一句话功能:** 基于 Wikipedia 指南，移除文本中的 AI 生成痕迹。
- **内部价值:** 中等。适用于对外 PR、技术博客编写、文档美化等场景。
- **建议标签:** `文案`, `降AI味`, `工具`
- **上架建议:** 可在个人空间或运营支持团队空间发布，全员可用。

### 3.5 个人成长/学习类
**Skill Name:** `english-immersion` & `ielts`
- **一句话功能:** 提供英语沉浸式环境校验与雅思备考知识库管理。
- **内部价值:** 较低（偏向个人属性），但可作为员工内部学习福利工具。
- **建议标签:** `英语`, `学习`, `个人提升`
- **上架建议:** 建议由作者在**个人空间**发布，并设置可见性为公开。

---

## 4. 后续上架操作建议
根据飞书文档，建议使用 **GitLab 仓库绑定自动发布** 方式来上架核心技能（如 `lark-doc-copywriting` 和 `darwin-skill`），流程如下：
1. 申请对应的 `team-` 空间。
2. 将 Skill 源码上传至内部 GitLab 仓库。
3. 在 Skill Hub 中进行 OAuth 授权与绑定。
4. 打上如 `v1.0.0` 的 Tag，触发自动同步与审核流程。
