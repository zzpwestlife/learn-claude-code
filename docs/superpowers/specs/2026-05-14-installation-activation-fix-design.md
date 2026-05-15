# Claude Code Installation Activation Fix Design

**日期**：2026-05-14  
**范围**：修复当前仓库在“安装到其他项目”后无法稳定激活 `statusline / cutover / handoff` 链路的问题，目标是实现目标项目内自动启用；只修项目内安装链路和 Claude settings 合并，不扩展为安装器整体重构。  

---

## 背景

当前仓库内的 token 优化与 soft guard 逻辑已经在本仓库通过验证，但安装到其他项目后存在两个关键断点：

1. `Session Cutover / Handoff` 依赖 `statusline.sh` 先写出 `.claude/tmp/session_usage_snapshot.json`，而安装流程目前不会自动为目标项目注册 `statusLine`，导致：
   - `statusline.sh` 很可能根本不运行；
   - `session-summary.sh` 在 `SessionEnd` 时拿不到 snapshot；
   - `CUTOVER` 与 `session_cutover.md` 这条链路在目标项目中退化为“不工作”。

2. 安装器当前对 `.claude/settings.json` 的合并策略对数组不友好：
   - `hooks.PreToolUse`、`hooks.SessionEnd` 这类数组在冲突时容易被整体覆盖；
   - 新增的 `Bash -> rtk-rewrite.sh` hook 无法保证进入已有目标项目的配置中。

也就是说，当前问题不是“功能代码无效”，而是“安装链路没有把运行时入口接通”。

---

## 目标（Goals）

1. **目标项目内自动启用**：执行安装后，目标项目默认具备完整链路：
   - `statusLine`
   - `session_usage_snapshot.json`
   - `SessionEnd -> session-summary.sh`
   - `session_cutover.md`
2. **结构化补丁 Claude settings**：对已有目标项目 `.claude/settings.json` 做最小、可预测的结构化补丁，而不是整文件粗暴覆盖。
3. **保持兼容性**：尽量不破坏目标项目已有的 `permissions`、已有 hook 或已有配置。
4. **可验证**：新增安装级验证，确认在临时目标目录运行 installer 后，所需配置与文件都已到位。

---

## 非目标（Non-Goals）

- 不重构整个 `install.sh`
- 不引入双模式安装链路（本轮只做项目内自动启用）
- 不继续依赖单独的全局 statusline 安装脚本作为主路径
- 不把 `config/manifest.json` 改造成 installer 的唯一真实驱动源
- 不修改现有 token/guard 功能本身的业务逻辑

---

## 方案概览

### Approach A：只补文档

在安装说明中明确要求用户安装后再单独执行全局 statusline 安装。

**优点**
- 改动最小

**缺点**
- 不满足“安装到其他项目后自动生效”
- 继续把生效责任推给用户

### Approach B（推荐）：项目内自动启用

安装器在复制 `.claude` 文件之外，主动修补目标项目 `.claude/settings.json`，把 `statusLine` 与必需 hooks 接通。

**优点**
- 最符合用户预期
- 问题收敛在 installer 和 settings merge
- 安装完成后即可直接验证

**缺点**
- 需要谨慎处理已有目标项目配置
- 需要为数组型 hook 配置实现定向合并

### Approach C：双模式支持

同时支持项目内自动启用与全局安装脚本并存。

**不选原因**
- 增加维护复杂度
- 很容易让诊断和文档变成双份逻辑

---

## 核心设计

## 1. 修复目标

### 需要自动接通的链路

目标项目安装完成后，至少应具备以下配置闭环：

- `statusLine.command = .claude/scripts/statusline.sh`
- `hooks.SessionEnd -> .claude/hooks/session-summary.sh`
- `hooks.PreToolUse matcher=Bash -> .claude/hooks/rtk-rewrite.sh`

### 已有文件安装

当前 installer 已经会复制 `.claude` 目录下的大多数内容，所以：

- hook 脚本文件本身通常会被复制过去
- skill 文档也会被复制过去

本轮不把重点放在“文件复制”，而放在“配置接通”。

---

## 2. Claude Settings 补丁策略

### 核心原则

- 不整文件覆盖目标项目 `.claude/settings.json`
- 不使用现有的通用 `smart_merge_json` 处理 hooks 数组
- 单独为 Claude settings 增加“按结构打补丁”的逻辑

### 为什么现有 JSON merge 不够

当前 `smart_merge_json` 对字典合并有效，但对数组没有语义级合并能力。  
对本场景来说，下面这些都需要“按身份识别”：

- `hooks.SessionEnd`
- `hooks.PreToolUse`
- `matcher = Bash`

如果继续使用通用 merge：

- 目标项目已有数组会整体覆盖源数组；
- 新增 hook 很容易被静默吞掉。

### 新补丁逻辑需要保证

#### `statusLine`

- 若目标项目缺少 `statusLine`，则补入：
  - `command: .claude/scripts/statusline.sh`

- 若目标项目已存在 `statusLine`：
  - 本轮不直接覆盖；
  - 记录安装提示或冲突提示；
  - 允许后续人工处理。

#### `hooks.SessionEnd`

- 确保存在一条 `command = .claude/hooks/session-summary.sh`
- 若已存在相同命令，不重复插入

#### `hooks.PreToolUse`

- 查找 `matcher = Bash`
- 若存在对应 matcher：
  - 只补入 `command = .claude/hooks/rtk-rewrite.sh`
  - 不覆盖已有 Bash hooks

- 若不存在对应 matcher：
  - 新增一个 `matcher = Bash` 的条目

---

## 3. 安装器改动范围

### 必须修改

- `scripts/installers/install.sh`

### 可能新增

- 一个内嵌 Python patch 逻辑
- 或一个小型 installer helper 脚本，专门处理 `.claude/settings.json`

### 为什么推荐独立补丁逻辑

把 Claude settings 的修补从通用 `safe_install / smart_merge_json` 中剥离，有三个好处：

- 逻辑更清晰
- 易于测试
- 避免对其他 JSON 文件引入意外副作用

---

## 4. 运行时验证设计

### 目标验证

在临时目标项目目录执行 installer 后，验证：

- `.claude/settings.json` 存在 `statusLine`
- `.claude/settings.json` 存在：
  - `hooks.SessionEnd -> session-summary.sh`
  - `hooks.PreToolUse matcher=Bash -> rtk-rewrite.sh`
- `.claude/scripts/statusline.sh` 文件已存在
- `.claude/hooks/session-summary.sh` 文件已存在

### 进一步验证

可用最小输入做一次运行时检查：

- 调用目标项目里的 `statusline.sh`
- 确认生成 `.claude/tmp/session_usage_snapshot.json`
- 再调用目标项目里的 `session-summary.sh`
- 确认能生成 `session_summary.md`

如果触发 `CUTOVER`，还应能看到 `session_cutover.md`

---

## 文件落点

### 必须修改

- `scripts/installers/install.sh`
- `tests/` 下新增 installer 回归测试

### 可能更新

- `.claude/settings.json`（作为源模板仍保留）
- `docs/setup/skill-telemetry-setup.md`
- `docs/reports/2026-05-14-token-optimization-summary.md`

---

## 验收标准（Success Criteria）

- [ ] 安装到临时目标项目后，目标项目 `.claude/settings.json` 自动包含 `statusLine`
- [ ] 安装到临时目标项目后，目标项目 `.claude/settings.json` 自动包含 `SessionEnd -> session-summary.sh`
- [ ] 安装到临时目标项目后，目标项目 `.claude/settings.json` 自动包含 `PreToolUse matcher=Bash -> rtk-rewrite.sh`
- [ ] 若目标项目已存在 `matcher=Bash`，新增 hook 以追加方式接入，而不是覆盖原条目
- [ ] 若目标项目已存在 `statusLine`，installer 不直接覆盖，并能明确提示
- [ ] 新增 installer 级回归测试通过
- [ ] `make test`、`make lint-skills`、`make check` 通过

---

## 风险与权衡

- **风险：修改 installer 影响现有安装行为**  
  缓解：只对 `.claude/settings.json` 增加专门补丁逻辑，不碰其他安装路径。

- **风险：目标项目已有复杂 Bash hooks，追加后执行顺序影响行为**  
  缓解：本轮只追加不替换，并把顺序策略写清楚且纳入测试。

- **风险：目标项目已有 `statusLine`，自动覆盖会破坏用户自定义配置**  
  缓解：本轮不覆盖，只提示冲突。

- **风险：文档与实际安装行为再次脱节**  
  缓解：新增 installer 级自动化验证，而不仅是文字说明。

---

## 开放问题（当前结论）

### 是否让 `config/manifest.json` 直接驱动 installer？

**结论：本轮不做。**  
先把“安装后不生效”的核心问题补平，再考虑 installer 架构统一。

### 是否保留全局 statusline 安装脚本？

**结论：保留，但不作为主链路。**  
项目内自动启用是本轮主路径；全局脚本后续仅作为附加能力存在。

### 是否把所有 hooks 都改成结构化补丁模式？

**结论：本轮只处理必需项。**  
先聚焦 `statusLine`、`SessionEnd`、`PreToolUse:Bash`。
