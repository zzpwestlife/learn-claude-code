#!/bin/bash
# FlowState 自动化验证脚本
# 一键检查所有 skills/commands/hooks/agents 的完整性与正确性
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0

pass() { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

# ─────────────────────────────────────────────────────────────
# 1. 文件完整性 — manifest.json 声明的组件是否存在
# ─────────────────────────────────────────────────────────────
check_manifest() {
  local total=0 found=0 missing=""

  for cmd in $(python3 -c "import json,sys; d=json.load(open('$ROOT_DIR/manifest.json')); [print(c) for c in d['components']['commands']]"); do
    total=$((total + 1))
    if [ -f "$ROOT_DIR/.claude/commands/${cmd}.md" ]; then
      found=$((found + 1))
    else
      missing="$missing ${cmd}.md"
    fi
  done

  for skill in $(python3 -c "import json,sys; d=json.load(open('$ROOT_DIR/manifest.json')); [print(s) for s in d['components']['skills']]"); do
    total=$((total + 1))
    if [ -f "$ROOT_DIR/.claude/skills/${skill}/SKILL.md" ]; then
      found=$((found + 1))
    else
      missing="$missing skills/${skill}/SKILL.md"
    fi
  done

  for agent in $(python3 -c "import json,sys; d=json.load(open('$ROOT_DIR/manifest.json')); [print(a) for a in d['components']['agents']]"); do
    total=$((total + 1))
    if [ -f "$ROOT_DIR/.claude/agents/${agent}.md" ]; then
      found=$((found + 1))
    else
      missing="$missing agents/${agent}.md"
    fi
  done

  if [ "$found" -eq "$total" ]; then
    pass "文件完整性: $found/$total files found"
  else
    fail "文件完整性: $found/$total files found, missing:$missing"
  fi
}
# ─────────────────────────────────────────────────────────────
# 2. 引用文件完整性 — SKILL.md/commands 中引用的 scripts/references/templates
# ─────────────────────────────────────────────────────────────
check_references() {
  local total=0 found=0 missing=""

  # Map of skill dirs that have SKILL.md
  for skill_dir in "$ROOT_DIR"/.claude/skills/*/; do
    [ -f "${skill_dir}SKILL.md" ] || continue
    local skill_name
    skill_name=$(basename "$skill_dir")

    # Check scripts/ references like scripts/foo.sh or scripts/foo.py
    for ref in $(grep -oE 'scripts/[a-zA-Z0-9_-]+\.(sh|py)' "${skill_dir}SKILL.md" 2>/dev/null || true); do
      total=$((total + 1))
      if [ -f "${skill_dir}${ref}" ]; then
        found=$((found + 1))
      else
        missing="$missing ${skill_name}/${ref}"
      fi
    done

    # Check references/ files
    for ref in $(grep -oE 'references/[a-zA-Z0-9_-]+\.md' "${skill_dir}SKILL.md" 2>/dev/null || true); do
      total=$((total + 1))
      if [ -f "${skill_dir}${ref}" ]; then
        found=$((found + 1))
      else
        missing="$missing ${skill_name}/${ref}"
      fi
    done

    # Check templates/ files
    for ref in $(grep -oE 'templates/[a-zA-Z0-9_-]+\.md' "${skill_dir}SKILL.md" 2>/dev/null || true); do
      total=$((total + 1))
      if [ -f "${skill_dir}${ref}" ]; then
        found=$((found + 1))
      else
        missing="$missing ${skill_name}/${ref}"
      fi
    done
  done

  if [ "$total" -eq 0 ]; then
    pass "引用文件完整性: no references to check"
  elif [ "$found" -eq "$total" ]; then
    pass "引用文件完整性: $found/$total references found"
  else
    fail "引用文件完整性: $found/$total references found, missing:$missing"
  fi
}

# ─────────────────────────────────────────────────────────────
# 3. 脚本权限 — 所有 .sh/.py 是否有可执行权限
# ─────────────────────────────────────────────────────────────
check_permissions() {
  local total=0 ok=0 bad=""
  while IFS= read -r f; do
    total=$((total + 1))
    if [ -x "$f" ]; then
      ok=$((ok + 1))
    else
      bad="$bad $(echo "$f" | sed "s|$ROOT_DIR/||")"
    fi
  done < <(find "$ROOT_DIR/.claude" -type f \( -name "*.sh" -o -name "*.py" \) -not -path "*/node_modules/*")

  if [ "$total" -eq 0 ]; then
    pass "脚本权限: no scripts found"
  elif [ "$ok" -eq "$total" ]; then
    pass "脚本权限: $ok/$total executable"
  else
    fail "脚本权限: $ok/$total executable, not executable:$bad"
  fi
}

# ─────────────────────────────────────────────────────────────
# 4. Bash 语法 — bash -n 检查所有 .sh
# ─────────────────────────────────────────────────────────────
check_bash_syntax() {
  local total=0 ok=0 bad=""
  while IFS= read -r f; do
    total=$((total + 1))
    if bash -n "$f" 2>/dev/null; then
      ok=$((ok + 1))
    else
      bad="$bad $(basename "$f")"
    fi
  done < <(find "$ROOT_DIR/.claude" -type f -name "*.sh" -not -path "*/node_modules/*")

  if [ "$total" -eq 0 ]; then
    pass "Bash 语法: no .sh files"
  elif [ "$ok" -eq "$total" ]; then
    pass "Bash 语法: $ok/$total passed"
  else
    fail "Bash 语法: $ok/$total passed, errors in:$bad"
  fi
}

# ─────────────────────────────────────────────────────────────
# 5. Python 语法 — ast.parse 检查所有 .py
# ─────────────────────────────────────────────────────────────
check_python_syntax() {
  local total=0 ok=0 bad=""
  while IFS= read -r f; do
    total=$((total + 1))
    if python3 -c "import ast; ast.parse(open('$f').read())" 2>/dev/null; then
      ok=$((ok + 1))
    else
      bad="$bad $(basename "$f")"
    fi
  done < <(find "$ROOT_DIR/.claude" -type f -name "*.py" -not -path "*/node_modules/*")

  if [ "$total" -eq 0 ]; then
    pass "Python 语法: no .py files"
  elif [ "$ok" -eq "$total" ]; then
    pass "Python 语法: $ok/$total passed"
  else
    fail "Python 语法: $ok/$total passed, errors in:$bad"
  fi
}

# ─────────────────────────────────────────────────────────────
# 6. Hook 触发 — claudeception-activator.sh 有输出
# ─────────────────────────────────────────────────────────────
check_hook_output() {
  local hook="$ROOT_DIR/.claude/hooks/claudeception-activator.sh"
  if [ ! -f "$hook" ]; then
    fail "Hook 触发: claudeception-activator.sh not found"
    return
  fi
  local output
  output=$(bash "$hook" 2>&1 || true)
  if [ -n "$output" ]; then
    pass "Hook 触发: claudeception-activator.sh produces output ($(echo "$output" | wc -l | tr -d ' ') lines)"
  else
    fail "Hook 触发: claudeception-activator.sh produces no output"
  fi
}

# ─────────────────────────────────────────────────────────────
# 7. check-complete.sh 状态机 — 模拟 4 种状态
# ─────────────────────────────────────────────────────────────
check_state_machine() {
  local script="$ROOT_DIR/.claude/skills/planning-with-files/scripts/check-complete.sh"
  if [ ! -f "$script" ]; then
    fail "状态机测试: check-complete.sh not found"
    return
  fi

  local tmpdir
  tmpdir=$(mktemp -d)

  # Ensure .claude/tmp exists for state files
  mkdir -p "$tmpdir/.claude/tmp" "$tmpdir/.claude/audit"

  local ok=0 total=4 bad=""

  # State 1: plan_ready — phases exist, none complete, none in_progress
  cat > "$tmpdir/task_plan.md" << 'PLAN'
**Status:** In Progress
### Phase 1: Setup [pending]
### Phase 2: Build [pending]
PLAN
  rm -f "$tmpdir/.claude/tmp"/phase_state_* 2>/dev/null || true
  local out
  out=$(cd "$tmpdir" && bash "$script" task_plan.md 2>/dev/null || true)
  if echo "$out" | grep -q "PLAN_READY"; then
    ok=$((ok + 1))
  else
    bad="$bad plan_ready"
  fi

  # State 2: in_progress — one phase in_progress
  cat > "$tmpdir/task_plan.md" << 'PLAN'
**Status:** In Progress
### Phase 1: Setup [in_progress]
### Phase 2: Build [pending]
PLAN
  rm -f "$tmpdir/.claude/tmp"/phase_state_* 2>/dev/null || true
  out=$(cd "$tmpdir" && bash "$script" task_plan.md 2>/dev/null || true)
  # in_progress = silent (no output or no event keyword)
  if [ -z "$out" ] || ! echo "$out" | grep -qE "PHASE_COMPLETE|ALL PHASES COMPLETE|PLAN_READY"; then
    ok=$((ok + 1))
  else
    bad="$bad in_progress"
  fi

  # State 3: phase_complete — phase 1 just completed (transition from 0 to 1)
  cat > "$tmpdir/task_plan.md" << 'PLAN'
**Status:** In Progress
### Phase 1: Setup [complete]
### Phase 2: Build [pending]
PLAN
  rm -f "$tmpdir/.claude/tmp"/phase_state_* 2>/dev/null || true
  echo "0" > "$tmpdir/.claude/tmp/phase_state_default"
  # Pre-seed state for the hash-based key too
  local plan_abs="$tmpdir/task_plan.md"
  local plan_hash
  plan_hash=$(echo "$plan_abs" | md5 -q 2>/dev/null || echo "$plan_abs" | md5sum 2>/dev/null | awk '{print $1}')
  [ -n "$plan_hash" ] && echo "0" > "$tmpdir/.claude/tmp/phase_state_${plan_hash}"
  out=$(cd "$tmpdir" && bash "$script" task_plan.md 2>/dev/null || true)
  if echo "$out" | grep -q "PHASE_COMPLETE"; then
    ok=$((ok + 1))
  else
    bad="$bad phase_complete"
  fi

  # State 4: all_complete — all phases done
  cat > "$tmpdir/task_plan.md" << 'PLAN'
**Status:** Complete
### Phase 1: Setup [complete]
### Phase 2: Build [complete]
PLAN
  rm -f "$tmpdir/.claude/tmp"/phase_state_* 2>/dev/null || true
  out=$(cd "$tmpdir" && bash "$script" task_plan.md 2>/dev/null || true)
  if echo "$out" | grep -q "ALL PHASES COMPLETE"; then
    ok=$((ok + 1))
  else
    bad="$bad all_complete"
  fi

  if [ "$ok" -eq "$total" ]; then
    pass "状态机测试: $ok/$total states verified"
  else
    fail "状态机测试: $ok/$total states verified, failed:$bad"
  fi

  rm -rf "$tmpdir"
}

# ─────────────────────────────────────────────────────────────
# 8. Prompt 关键字 — 检查 command/skill 是否包含关键模板元素
# ─────────────────────────────────────────────────────────────
check_prompt_keywords() {
  local total=0 ok=0 bad=""

  # Check commands
  for f in "$ROOT_DIR"/.claude/commands/*.md; do
    [ -f "$f" ] || continue
    local name
    name=$(basename "$f")
    total=$((total + 1))
    local issues=""

    # Visual Progress Bar (optimize-prompt, review-code, changelog-generator, commit-message-generator all have it)
    if ! grep -qE '(Progress|Optimize.*Plan.*Execute|✔|➤)' "$f" 2>/dev/null; then
      issues="${issues}no-progress-bar "
    fi

    # TUI handoff template (────── border or Tab-to-Execute)
    if ! grep -qE '(─────|Tab-to-Execute|RunCommand)' "$f" 2>/dev/null; then
      issues="${issues}no-TUI "
    fi

    if [ -z "$issues" ]; then
      ok=$((ok + 1))
    else
      bad="$bad ${name}(${issues% })"
    fi
  done

  # Check skills — skip if a same-name command already provides TUI handoff,
  # or if the skill is a meta/utility tool (not part of the main workflow)
  local meta_skills="skill-architect wechat-draft-sync"
  for skill_dir in "$ROOT_DIR"/.claude/skills/*/; do
    [ -f "${skill_dir}SKILL.md" ] || continue
    local skill_name
    skill_name=$(basename "$skill_dir")

    # Skip meta/utility skills that don't participate in workflow handoff
    if echo " $meta_skills " | grep -q " $skill_name "; then
      continue
    fi

    # If a matching command file exists and already has TUI, the skill doesn't need it
    if [ -f "$ROOT_DIR/.claude/commands/${skill_name}.md" ]; then
      if grep -qE '(─────|Tab-to-Execute|RunCommand)' "$ROOT_DIR/.claude/commands/${skill_name}.md" 2>/dev/null; then
        continue
      fi
    fi

    total=$((total + 1))
    local issues=""

    # TUI handoff or RunCommand reference
    if ! grep -qE '(─────|Tab-to-Execute|RunCommand|Handoff)' "${skill_dir}SKILL.md" 2>/dev/null; then
      issues="${issues}no-TUI "
    fi

    if [ -z "$issues" ]; then
      ok=$((ok + 1))
    else
      bad="$bad ${skill_name}(${issues% })"
    fi
  done

  if [ "$ok" -eq "$total" ]; then
    pass "Prompt 关键字: $ok/$total contain required patterns"
  else
    fail "Prompt 关键字: $ok/$total passed, issues:$bad"
  fi
}

# ─────────────────────────────────────────────────────────────
# 9. 工具名合法性 — allowed-tools 中的工具名是否在已知列表内
# ─────────────────────────────────────────────────────────────
check_tool_names() {
  # Known valid Claude Code tool names
  local known_tools="Read Write Edit MultiEdit Bash Glob Grep WebFetch WebSearch AskUserQuestion RunCommand LS Task TodoRead TodoWrite"
  local total=0 ok=0 bad=""

  for f in "$ROOT_DIR"/.claude/commands/*.md "$ROOT_DIR"/.claude/skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    local fname
    fname=$(echo "$f" | sed "s|$ROOT_DIR/.claude/||")

    # Extract tool names from allowed-tools YAML block
    local in_block=0
    while IFS= read -r line; do
      if echo "$line" | grep -q "^allowed-tools:"; then
        in_block=1
        continue
      fi
      if [ "$in_block" -eq 1 ]; then
        # End of block: line doesn't start with "  -" and isn't empty
        if echo "$line" | grep -qE '^  - '; then
          # Extract tool name — handle "Bash(go vet *, ...)" patterns
          local tool
          tool=$(echo "$line" | sed 's/^  - //' | sed 's/(.*//' | tr -d ' ')
          total=$((total + 1))
          if echo " $known_tools " | grep -q " $tool "; then
            ok=$((ok + 1))
          else
            bad="$bad ${fname}:${tool}"
          fi
        elif echo "$line" | grep -qE '^[a-z]|^---'; then
          in_block=0
        fi
      fi
    done < "$f"
  done

  if [ "$total" -eq 0 ]; then
    pass "工具名合法性: no allowed-tools declarations found"
  elif [ "$ok" -eq "$total" ]; then
    pass "工具名合法性: $ok/$total tool names valid"
  else
    fail "工具名合法性: $ok/$total valid, unknown:$bad"
  fi
}

# ─────────────────────────────────────────────────────────────
# 10. 无硬编码路径 — .claude/ 下无 /Users/ 或 /home/ 硬编码
# ─────────────────────────────────────────────────────────────
check_no_hardcoded_paths() {
  local hits
  # Exclude settings.local.json (local config naturally contains machine-specific paths)
  hits=$(grep -rn '/Users/\|/home/' "$ROOT_DIR/.claude/" \
    --include="*.md" --include="*.sh" --include="*.py" --include="*.json" \
    --exclude="settings.local.json" \
    -l 2>/dev/null || true)

  if [ -z "$hits" ]; then
    pass "无硬编码路径: no /Users/ or /home/ found in .claude/"
  else
    local count
    count=$(echo "$hits" | wc -l | tr -d ' ')
    local files
    files=$(echo "$hits" | sed "s|$ROOT_DIR/.claude/||g" | tr '\n' ' ')
    fail "无硬编码路径: found in $count file(s): $files"
  fi
}

# ─────────────────────────────────────────────────────────────
# 11. fib 示例测试 — 运行 unittest
# ─────────────────────────────────────────────────────────────
check_fib_tests() {
  if [ ! -f "$ROOT_DIR/fib/test_fibonacci.py" ]; then
    fail "fib 测试: test_fibonacci.py not found"
    return
  fi
  local output
  output=$(cd "$ROOT_DIR/fib" && python3 -m pytest test_fibonacci.py -q 2>&1 || \
           cd "$ROOT_DIR/fib" && python3 -m unittest test_fibonacci -v 2>&1 || true)
  if echo "$output" | grep -qE '(passed|OK)'; then
    pass "fib 测试: all tests passed"
  else
    fail "fib 测试: tests failed — $(echo "$output" | tail -1)"
  fi
}

# ─────────────────────────────────────────────────────────────
# Run all checks
# ─────────────────────────────────────────────────────────────
echo "FlowState Verification Script"
echo "=============================="
echo ""

check_manifest
check_references
check_permissions
check_bash_syntax
check_python_syntax
check_hook_output
check_state_machine
check_prompt_keywords
check_tool_names
check_no_hardcoded_paths
check_fib_tests

echo ""
echo "=============================="
echo "Summary: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
