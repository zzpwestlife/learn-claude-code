#!/bin/bash
LOG_FILE="/tmp/claude_lsp_debug.log"
echo "----------------------------------------------------------------" >> "$LOG_FILE"
echo "$(date): gopls wrapper called" >> "$LOG_FILE"
echo "CWD: $(pwd)" >> "$LOG_FILE"
echo "Args: $@" >> "$LOG_FILE"
echo "PATH: $PATH" >> "$LOG_FILE"

# 确保 gopls 在路径中，或者使用绝对路径
GOPLS_CMD="/Users/joeyzou/go/bin/gopls"

if [ ! -x "$GOPLS_CMD" ]; then
    echo "Error: gopls not found at $GOPLS_CMD" >> "$LOG_FILE"
    exit 1
fi

# 执行 gopls 并捕获 stderr
"$GOPLS_CMD" "$@" 2>> "$LOG_FILE"
