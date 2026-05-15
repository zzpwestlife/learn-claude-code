#!/bin/bash

# Session End Hook: Scan for Tweet Material
# Usage: This script runs automatically when the Claude Code session ends.

LOG_FILE=".claude/tmp/session_summary.md"
DATE=$(date +"%Y-%m-%d %H:%M:%S")
SNAPSHOT_FILE=".claude/tmp/session_usage_snapshot.json"
CUTOVER_FILE=".claude/tmp/session_cutover.md"
CUTOVER_API_THRESHOLD="${CLAUDE_SOFT_GUARD_API_THRESHOLD:-30}"
CUTOVER_OUTPUT_THRESHOLD="${CLAUDE_SOFT_GUARD_OUTPUT_THRESHOLD:-50000}"
CUTOVER_CACHE_READ_THRESHOLD="${CLAUDE_SOFT_GUARD_CACHE_READ_THRESHOLD:-2000000}"
STATUS_LINES=""

sanitize_commit_message() {
    local message="$1"

    message="${message#feat: }"
    message="${message#fix: }"
    message="${message#chore: }"
    message="${message#docs: }"
    message="${message#refactor: }"
    message="${message#test: }"
    message="${message#add }"
    message="${message#update }"

    printf '%s' "$message"
}

echo "# Session Summary - $DATE" > "$LOG_FILE"
echo "" >> "$LOG_FILE"
rm -f "$CUTOVER_FILE"

# 1. Check Git Activity (Commits since session start - simplified to 'last 1 hour' or just recent)
echo "## Recent Git Activity" >> "$LOG_FILE"
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    git log --since="1 hour ago" --oneline --no-merges >> "$LOG_FILE"
else
    echo "No git repository found." >> "$LOG_FILE"
fi

echo "" >> "$LOG_FILE"

# 2. Check Modified Files
echo "## Modified Files" >> "$LOG_FILE"
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    STATUS_LINES=$(git status --short --untracked-files=all 2>/dev/null)
    if [ -n "$STATUS_LINES" ]; then
        printf '%s\n' "$STATUS_LINES" >> "$LOG_FILE"
    fi
else
    echo "No git repository found." >> "$LOG_FILE"
fi

echo "" >> "$LOG_FILE"

# 3. Session Guard
echo "## Session Guard" >> "$LOG_FILE"
if [ -f "$SNAPSHOT_FILE" ]; then
    GUARD_STATUS=$(jq -r '.guard_status // "UNKNOWN"' "$SNAPSHOT_FILE")
    API_REQUESTS=$(jq -r '.api_requests // 0' "$SNAPSHOT_FILE")
    OUTPUT_TOKENS=$(jq -r '.output_tokens // 0' "$SNAPSHOT_FILE")
    CACHE_READ_TOKENS=$(jq -r '.cache_read_input_tokens // 0' "$SNAPSHOT_FILE")
    CONTINUED_SESSION=$(jq -r '.continued_session // false' "$SNAPSHOT_FILE")

    if [ "$GUARD_STATUS" = "UNKNOWN" ]; then
        GUARD_STATUS="OK"
        if [ "$CACHE_READ_TOKENS" -ge "$CUTOVER_CACHE_READ_THRESHOLD" ] || \
            [ "$OUTPUT_TOKENS" -ge "$CUTOVER_OUTPUT_THRESHOLD" ] || \
            [ "$API_REQUESTS" -ge "$CUTOVER_API_THRESHOLD" ] || \
            [ "$CONTINUED_SESSION" = "true" ]; then
            GUARD_STATUS="CUTOVER"
        fi
    fi

    if [ "$GUARD_STATUS" = "CUTOVER" ]; then
        echo "- 建议切新 session：当前会话已接近长上下文泥潭。" >> "$LOG_FILE"
        echo "- 原因：输出 token、cache read token、请求次数或续接状态已触发阈值。" >> "$LOG_FILE"
    else
        echo "- 当前无需切换 session。" >> "$LOG_FILE"
    fi
else
    echo "- 未检测到 usage snapshot，跳过 session guard 收口建议。" >> "$LOG_FILE"
fi

echo "" >> "$LOG_FILE"

# 4. Suggest Tweet (Simple Heuristic)
echo "## Tweet Suggestions" >> "$LOG_FILE"
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    COMMIT_COUNT=$(git log --since="1 hour ago" --oneline --no-merges 2>/dev/null | wc -l | tr -d ' ')
    RECENT_COMMIT=$(git log --since="1 hour ago" --oneline --no-merges 2>/dev/null | head -n 1)
else
    COMMIT_COUNT=0
    RECENT_COMMIT=""
fi
if [ "$COMMIT_COUNT" -gt 0 ]; then
    echo "- 🚀 Just shipped $COMMIT_COUNT updates in #ClaudeCode!" >> "$LOG_FILE"
    echo "- 💡 Learned a lot about $(git log --since="1 hour ago" --oneline | head -n 1 | cut -d' ' -f2-) today." >> "$LOG_FILE"
else
    echo "- 🤔 Spent some time planning and exploring code." >> "$LOG_FILE"
fi

if [ "$GUARD_STATUS" = "CUTOVER" ]; then
    CURRENT_TASK_LINE="- 需要人工补充"
    if [ -n "$RECENT_COMMIT" ]; then
        RECENT_COMMIT_MESSAGE=$(printf '%s' "$RECENT_COMMIT" | cut -d' ' -f2-)
        RECENT_COMMIT_MESSAGE=$(sanitize_commit_message "$RECENT_COMMIT_MESSAGE")
        WHAT_CHANGED_LINE="- Recent commit: $RECENT_COMMIT"
    else
        WHAT_CHANGED_LINE="- No recent commit detected."
    fi

    if [ -n "$RECENT_COMMIT_MESSAGE" ]; then
        CURRENT_TASK_LINE="- 正在处理：$RECENT_COMMIT_MESSAGE"
    elif [ -n "$STATUS_LINES" ]; then
        if printf '%s\n' "$STATUS_LINES" | grep -q 'session-summary.sh' && printf '%s\n' "$STATUS_LINES" | grep -q 'test_soft_token_guards.py'; then
            CURRENT_TASK_LINE="- 正在处理 session-summary 与 soft token guard 相关工作"
        else
            FIRST_PATH=$(printf '%s\n' "$STATUS_LINES" | head -n 1 | cut -c4-)
            FIRST_PATH="${FIRST_PATH##*/}"
            if [ -n "$FIRST_PATH" ]; then
                CURRENT_TASK_LINE="- 正在处理 ${FIRST_PATH} 相关工作"
            fi
        fi
    fi

    OPEN_ISSUES=()
    if [ -n "$STATUS_LINES" ]; then
        OPEN_ISSUES+=("- 仍有未提交改动，建议新会话先确认本轮修改边界")
    fi
    if [ "$COMMIT_COUNT" -eq 0 ]; then
        OPEN_ISSUES+=("- 最近没有提交记录，可能仍处于探索或整理阶段")
    fi
    OPEN_ISSUES+=("- 当前会话已触发 cutover，建议新会话先确认第一优先任务")

    if [ "${#OPEN_ISSUES[@]}" -eq 0 ]; then
        OPEN_ISSUES=("- 需要人工补充当前未完成事项")
    fi

    {
        echo "# Session Cutover Handoff"
        echo
        echo "## Current Task"
        echo "$CURRENT_TASK_LINE"
        echo
        echo "## What Changed"
        echo "$WHAT_CHANGED_LINE"
        echo
        echo "## Open Issues"
        for issue in "${OPEN_ISSUES[@]:0:3}"; do
            echo "$issue"
        done
        echo
        echo "## Suggested Next Prompt"
        echo "继续处理当前任务。先阅读 session_cutover.md，然后："
        echo "1. 确认 Current Task 是否准确"
        echo "2. 优先处理 Open Issues 的第一项"
        echo "3. 保持修改范围最小，完成后运行对应验证"
        echo
        echo "## Why Cutover"
        echo "- API requests: $API_REQUESTS"
        echo "- Output tokens: $OUTPUT_TOKENS"
        echo "- Cache read tokens: $CACHE_READ_TOKENS"
        echo "- Continued session: $CONTINUED_SESSION"
    } > "$CUTOVER_FILE"
fi

echo "Session summary saved to $LOG_FILE"
