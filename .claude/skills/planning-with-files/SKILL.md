name: planning-with-files
version: "2.13.0"
description: Implements Manus-style file-based planning for complex tasks. Creates task_plan.md, findings.md, and progress.md. Use when starting complex multi-step tasks, research projects, or any task requiring >5 tool calls. Now with automatic session recovery after /clear.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - WebFetch
  - WebSearch
  - AskUserQuestion
  - RunCommand
hooks:
  PostToolUse:
    - matcher: "Write|Edit|Bash"
      hooks:
        - type: command
          command: |
            # Find project root by walking up to find .claude
            d="$PWD"; ROOT_DIR=""; while [ "$d" != "/" ]; do if [ -d "$d/.claude" ]; then ROOT_DIR="$d"; break; fi; d=$(dirname "$d"); done; if [ -z "$ROOT_DIR" ]; then ROOT_DIR="$PWD"; fi
            
            SCRIPT_DIR="$ROOT_DIR/.claude/skills/planning-with-files/scripts"
            
            # Attempt to find task_plan.md in current dir, immediate subdirs, or project root
            PLAN_FILE=$(find . -maxdepth 2 -name task_plan.md -not -path '*/.*' 2>/dev/null | head -n 1)
            if [ -z "$PLAN_FILE" ]; then
                if [ -f "$ROOT_DIR/task_plan.md" ]; then
                    PLAN_FILE="$ROOT_DIR/task_plan.md"
                else
                    PLAN_FILE="task_plan.md"
                fi
            fi
            
            OUTPUT=$(sh "$SCRIPT_DIR/check-complete.sh" "$PLAN_FILE" 2>/dev/null)
            
            # Concise output: only show status if changed or complete
            if echo "$OUTPUT" | grep -q "ALL PHASES COMPLETE"; then
              echo ""
              echo "<system-reminder>"
              echo "✅ SYSTEM NOTICE: All phases in task_plan.md are complete."
              echo "👉 ACTION REQUIRED: To maintain a zero-friction workflow, you MUST now PROPOSE the next step:"
              echo "  1. Summarize the completed work briefly."
              echo "  2. Use the 'RunCommand' tool IMMEDIATELY to propose the Code Review:"
              echo "     - command: '/review-code'"
              echo "     - requires_approval: true"
              echo "     - message: 'All phases complete. Press Tab to start Code Review.'"
              echo "  DO NOT ask the user if they want to review. Just propose the command so they can Tab-to-Execute."
              echo "</system-reminder>"
            elif [ -n "$OUTPUT" ]; then
              # Write detailed status to a temp file to keep chat clean
                    mkdir -p .claude/tmp
                    echo "$OUTPUT" > .claude/tmp/planning_status.md
                    echo "Planning Status Updated: [View Status](file:///Users/admin/openSource/learn-claude-code/.claude/tmp/planning_status.md)"
                    
                    # If not complete, remind model to STOP after single phase in Execute mode
                    echo "<system-reminder>"
                    echo "🛑 STOP! EXECUTION PAUSE REQUIRED 🛑"
                    echo "You have completed a phase. You MUST STOP NOW."
                    echo "DO NOT proceed to the next phase."
                    echo "👉 ACTION REQUIRED: Use 'RunCommand' to propose the next step:"
                    echo "     - command: '/planning-with-files:execute'"
                    echo "     - requires_approval: true"
                    echo "     - message: 'Phase complete. Press Tab to execute next phase, or edit plan/code first.'"
                    echo "</system-reminder>"
            fi
  Stop:
    - hooks:
        - type: command
          command: |
            SCRIPT_DIR="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/planning-with-files}/scripts"

            IS_WINDOWS=0
            if [ "${OS-}" = "Windows_NT" ]; then
              IS_WINDOWS=1
            else
              UNAME_S="$(uname -s 2>/dev/null || echo '')"
              case "$UNAME_S" in
                CYGWIN*|MINGW*|MSYS*) IS_WINDOWS=1 ;;
              esac
            fi
            
            # Check completion status on session stop
            sh "$SCRIPT_DIR/check-complete.sh" "task_plan.md" 2>/dev/null | grep -q "ALL PHASES COMPLETE"
            if [ $? -eq 0 ]; then
                echo ""
                echo "🎉 **Plan Execution Complete!**"
                echo "The next logical step is to review the code changes."
                echo "👉 **Proposed Command:** \`/review-code\`"
                echo "(Please execute the proposed command below to proceed)"
            fi

            if [ "$IS_WINDOWS" -eq 1 ]; then
              if command -v pwsh >/dev/null 2>&1; then
                pwsh -ExecutionPolicy Bypass -File "$SCRIPT_DIR/check-complete.ps1" 2>/dev/null ||
                powershell -ExecutionPolicy Bypass -File "$SCRIPT_DIR/check-complete.ps1" 2>/dev/null ||
                sh "$SCRIPT_DIR/check-complete.sh"
              else
                powershell -ExecutionPolicy Bypass -File "$SCRIPT_DIR/check-complete.ps1" 2>/dev/null ||
                sh "$SCRIPT_DIR/check-complete.sh"
              fi
            else
              sh "$SCRIPT_DIR/check-complete.sh"
            fi
---

# Planning with Files

Work like Manus: Use persistent markdown files as your "working memory on disk."

## Modes

1.  **Plan** (Default): Create or update planning files (`task_plan.md`, `findings.md`, `progress.md`).
    -   **VISUAL**: Start output with `[✔ Optimize] → [➤ Plan] → [Execute] → [Review] → [Changelog] → [Commit]`
    -   **PHASE 0: SOCRATIC INTERVIEW (Mandatory)**:
        -   Before generating the plan, you **MUST** pause and consider: "Do I have enough context to build a solid architectural plan?"
        -   If unsure about *Tech Stack*, *Testing Strategy*, *Edge Cases*, or *User Preferences*, use `AskUserQuestion` **IMMEDIATELY**.
        -   **Format**: Use the TUI-style format:
            ```
            ────────────────────────────────────────────────────────────────────────────────
            ←  ☐ Tech Stack  ☐ Architecture  ☐ Testing  ✔ Plan Generation  →
            
            为了确保方案的稳健性，我需要确认以下关键点：
            
            1. [Question 1]
               [Description]
            2. [Question 2]
               [Description]
            ...
            ────────────────────────────────────────────────────────────────────────────────
            ```
    -   **GOAL**: ONLY create/update the plan.
    -   **FORBIDDEN**: DO NOT execute any tasks. DO NOT create code files (except plan files).
    -   **STOP**: Terminate immediately after writing the plan files.
2.  **Execute** (Triggered by arg `execute` or command `/planning-with-files:execute`):
    -   **VISUAL**: Start output with `[✔ Optimize] → [✔ Plan] → [➤ Execute] → [Review] → [Changelog] → [Commit]`
    -   **SINGLE PHASE GUARANTEE (STRICT)**:
        -   You are authorized to complete **EXACTLY ONE (1)** phase per turn.
        -   **NEVER** chain multiple phases. **NEVER** "just do the next one".
        -   **VIOLATION**: Executing >1 phase triggers a critical workflow failure.
    -   **ATOMIC EXECUTION RULE**:
        1.  Read `task_plan.md` to identify the **single next pending phase**.
        2.  Execute the tasks for that phase **ONLY**.
        3.  Update `progress.md`.
        4.  **STOP IMMEDIATELY**.
    -   **INTERACTIVE HANDOFF (MANDATORY)**:
        -   You MUST pause after updating `progress.md` and present options.
        -   Use `AskUserQuestion` to ask "What's next?" (See Workflow Handoff section).

## FIRST: Check for Previous Session (v2.2.0)

**Before starting work**, check for unsynced context from a previous session:

```bash
# Linux/macOS
$(command -v python3 || command -v python) ${CLAUDE_PLUGIN_ROOT}/scripts/session-catchup.py "$(pwd)"
```

```powershell
# Windows PowerShell
& (Get-Command python -ErrorAction SilentlyContinue).Source "$env:USERPROFILE\.claude\skills\planning-with-files\scripts\session-catchup.py" (Get-Location)
```

If catchup report shows unsynced context:
1. Run `git diff --stat` to see actual code changes
2. Read current planning files
3. Update planning files based on catchup + git diff
4. Then proceed with task

## Workflow Handoff (Zero-Friction + User Control)

**When Planning (Mode 1) is Complete:**
After you have successfully created or updated the planning files (`task_plan.md`, etc.):

1.  **STOP IMMEDIATELY**:
    -   **DO NOT** execute any tasks from the plan yet.
    -   **DO NOT** create project directories or code files yet.
    -   The user **MUST** have the opportunity to review and modify the plan.

2.  **Summary**: Briefly list the created files and the current status (e.g., "Phase 1 Ready").

3.  **Reflective Handoff (Visual TUI)**:
    -   Display a clear TUI-style menu for the final decision.
    -   Use the following format:
        ```text
        ────────────────────────────────────────────────────────────────────────────────
        ←  ✔ Optimize  ✔ Plan  ☐ Execute  →

        Planning 完成。请审查 task_plan.md。下一步：

        ❯ 1. 执行计划 (Execute Plan)
             开始执行 Phase 1
          2. 修改计划 (Modify Plan)
             需要调整任务或架构
          3. 查看文件 (View Files)
             cat task_plan.md
        ────────────────────────────────────────────────────────────────────────────────
        ```

4.  **Action**:
    -   Use `AskUserQuestion` to capture the user's choice.
    -   **Option 1 (Execute)**: If selected, IMMEDIATELY call `RunCommand` with `/planning-with-files:execute` (requires_approval: true).
    -   **Option 2 (Modify)**: If selected, ask for specific feedback and loop back to planning.
    -   **Option 3 (View)**: If selected, use `RunCommand` to `cat task_plan.md` and then re-display the menu.
    -   **Custom Input**: If user types feedback directly, loop back to planning.

**When Execution (Mode 2) is Complete:**
After completing a **single phase**:

1.  **Summary**: Report completion of the current phase.
2.  **Reflective Handoff (Visual TUI)**:
    -   Display a clear TUI-style menu for the final decision.
    -   Use the following format:
        ```text
        ────────────────────────────────────────────────────────────────────────────────
        ←  ✔ Phase [X]  ☐ Phase [X+1]  →

        Phase [X] 已完成。下一步：

        ❯ 1. 继续执行 (Proceed to Phase [X+1])
             开始执行下一阶段任务
          2. 暂停/审查 (Pause & Review)
             检查代码或修改计划
          3. 提交更改 (Commit Changes)
             git commit -m "Phase [X] complete"
        ────────────────────────────────────────────────────────────────────────────────
        ```

3.  **Action**:
    -   Use `AskUserQuestion` to capture the user's choice.
    -   **Option 1 (Proceed)**: Call `RunCommand` with `/planning-with-files:execute` (requires_approval: true).
    -   **Option 2 (Pause)**: Stop and yield control.
    -   **Option 3 (Commit)**: Call `RunCommand` with `git commit`.

## Important: Where Files Go

- **Templates** are in `${CLAUDE_PLUGIN_ROOT}/templates/`
- **Your planning files** go in **your project directory**
