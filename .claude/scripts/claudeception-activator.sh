#!/usr/bin/env bash
# Smart Skill Architect Activator
# Detects task-completion signals, dedupes repeated reminders, and keeps output compact.

LOG_FILE=".claude/logs/activator.log"
CACHE_FILE=".claude/tmp/claudeception-activator.cache"
THRESHOLD="${CLAUDECEPTION_ACTIVATOR_THRESHOLD_SECONDS:-300}"
CACHE_TTL="${CLAUDECEPTION_ACTIVATOR_CACHE_SECONDS:-1800}"
WINDOW_SIZE="${CLAUDECEPTION_ACTIVATOR_WINDOW_SIZE:-5}"

mkdir -p "$(dirname "$LOG_FILE")" "$(dirname "$CACHE_FILE")"

is_disabled() {
    case "${ENABLE_SKILL_ARCHITECT_ACTIVATOR:-1}" in
        0|false|FALSE|no|NO|off|OFF) return 0 ;;
        *) return 1 ;;
    esac
}

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

file_mtime() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        stat -f %m "$1"
    else
        stat -c %Y "$1"
    fi
}

file_age() {
    local modified now
    modified=$(file_mtime "$1" 2>/dev/null) || return 1
    now=$(date +%s)
    echo $((now - modified))
}

find_latest_plan() {
    [ -d "docs/plans" ] || return 1
    if [[ "$OSTYPE" == "darwin"* ]]; then
        find docs/plans -name "*.md" -type f -exec stat -f "%m %N" {} + | sort -rn | head -n 1 | cut -d ' ' -f 2-
    else
        find docs/plans -name "*.md" -type f -exec stat -c "%Y %n" {} + | sort -rn | head -n 1 | cut -d ' ' -f 2-
    fi
}

detect_signal() {
    local age latest_plan

    if [ -f "CHANGELOG.md" ]; then
        age=$(file_age "CHANGELOG.md")
        if [ "$age" -lt "$THRESHOLD" ]; then
            echo "changelog|CHANGELOG.md updated ${age}s ago"
            return 0
        fi
    fi

    latest_plan=$(find_latest_plan)
    if [ -n "$latest_plan" ] && ! grep -q "\- \[ \]" "$latest_plan"; then
        age=$(file_age "$latest_plan")
        if [ "$age" -lt "$THRESHOLD" ]; then
            echo "plan:$(basename "$latest_plan")|Plan $(basename "$latest_plan") completed ${age}s ago"
            return 0
        fi
    fi

    for review_file in CODE_REVIEW.md review_report.md; do
        if [ -f "$review_file" ]; then
            age=$(file_age "$review_file")
            if [ "$age" -lt "$THRESHOLD" ]; then
                echo "review:$review_file|$review_file generated ${age}s ago"
                return 0
            fi
        fi
    done

    return 1
}

prune_cache() {
    local now
    local kept
    local pruned
    [ -f "$CACHE_FILE" ] || return 1
    now=$(date +%s)
    kept=$(awk -F'|' -v now="$now" -v ttl="$CACHE_TTL" '
        NF >= 2 && (now - $1) < ttl { print $0 }
    ' "$CACHE_FILE")
    if [ -n "$kept" ]; then
        pruned=$(printf '%s\n' "$kept" | tail -n "$WINDOW_SIZE")
        printf '%s\n' "$pruned" > "$CACHE_FILE"
        return 0
    fi
    : > "$CACHE_FILE"
    return 1
}

should_skip_cached_signal() {
    local signal_key="$1"
    prune_cache || return 1
    awk -F'|' -v key="$signal_key" 'NF >= 2 && $2 == key { found=1 } END { exit found ? 0 : 1 }' "$CACHE_FILE"
}

cache_signal() {
    local tmp_file
    prune_cache >/dev/null 2>&1 || true
    tmp_file=$(mktemp "${CACHE_FILE}.XXXXXX")
    {
        [ -s "$CACHE_FILE" ] && cat "$CACHE_FILE"
        printf '%s|%s\n' "$(date +%s)" "$1"
    } | tail -n "$WINDOW_SIZE" > "$tmp_file"
    mv "$tmp_file" "$CACHE_FILE"
}

print_prompt() {
    local reason="$1"
    cat <<EOF
[Skill Architect] Completion signal: $reason
- New reusable workflow or capability: create/refine a skill.
- New bug fix, prompt tweak, or preference: save it into existing skill memory.
EOF
}

if is_disabled; then
    log "SKIPPED: activator disabled by env"
    exit 0
fi

SIGNAL=$(detect_signal) || exit 0
SIGNAL_KEY=${SIGNAL%%|*}
REASON=${SIGNAL#*|}

if should_skip_cached_signal "$SIGNAL_KEY"; then
    log "SKIPPED: cached duplicate for $SIGNAL_KEY"
    exit 0
fi

cache_signal "$SIGNAL_KEY"
log "ACTIVATED: $REASON"
print_prompt "$REASON"
exit 0
