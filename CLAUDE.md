# CLAUDE.md - FlowState Workflow Protocols

## 1. 核心原则 (Core Principles)
- **Atomic Execution (原子化执行)**: 每次交互仅执行**一个**步骤 (Step) 或任务阶段 (Phase)。严禁跨越自动执行。
- **Interactive Handoff (交互式交接)**: 每个 Step/Phase 结束后，**必须**展示 TUI 菜单并等待用户指令。
- **File-First (文件优先)**: 所有长内容（>10行）必须写入文件，聊天窗口仅保留摘要。
- **Source of Truth (单一真理)**: `task_plan.md` 是任务状态的唯一真理。必须先更新文件，再宣称 Phase 完成。

## 2. 工作流规范 (Workflow Specification)

### Step 1: Optimization (Prompt Engineering)
1. **Command**: `/optimize-prompt`
2. **Action**: 交互式优化提示词 -> 生成 `prompt.md`。
3. **Handoff**: 展示 TUI -> 用户选择 "Proceed to Planning" -> 执行 `/planning-with-files:plan`。

### Step 2: Planning (Architecture & Task Breakdown)
1. **Command**: `/planning-with-files:plan`
2. **Action**: 读取 `prompt.md` -> 生成 `task_plan.md`, `findings.md`。
3. **Constraint**: **STOP** immediately after file generation.
4. **Handoff**: 展示 TUI -> 用户选择 "Execute Plan" -> 执行 `/planning-with-files:execute`。

### Step 3: Execution (The Loop - Task Phases)
1. **Command**: `/planning-with-files:execute`
2. **Action**: 读取 `task_plan.md` -> 执行当前 `in_progress` 的 **Task Phase**。
3. **Completion**:
   - 完成该 Phase 的代码与测试。
   - 更新 `task_plan.md` (Mark Phase as `[x]`).
4. **MANDATORY STOP (关键控制点)**:
   - 更新文件后，系统会触发 "STOP EXECUTION NOW" 警告。
   - **必须** 响应此警告，停止思考，展示 TUI。
5. **Handoff**:
   - 展示 "Phase [X] Complete" TUI 菜单。
   - 选项: [Continue], [Pause], [Review]。

## 3. TUI 交互标准 (Interaction Standards)

### Execution Step TUI (Task Phase Handoff)
所有 Task Phase 完成后的 Handoff 必须使用以下 ASCII 格式：

```text
────────────────────────────────────────────────────────────────────────────────
←  ✔ Phase [X]  ☐ Phase [X+1]  →

Phase [X] 已完成。下一步：

❯ 1. 继续执行 (Proceed)
     执行 /planning-with-files:execute {output_dir}
  2. 暂停/审查 (Pause & Review)
     退出并等待
  3. 提交更改 (Commit)
     执行 git commit
────────────────────────────────────────────────────────────────────────────────
```

## 4. 验证与强制机制 (Enforcement)
- **Hook Verification**: 每次 `Write` 操作后，`check-complete.sh` 会自动运行。
- **Stop Signal**: 如果脚本检测到 Task Phase 完成，会输出 `🛑 STOP EXECUTION NOW 🛑`。
- **Protocol**: 见到此信号，**必须**立即停止当前推理链，转入 TUI 交互模式。
