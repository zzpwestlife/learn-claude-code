---
name: notifier
description: Unified Notification Center for Claude Code Agents
tools:
  - notify
---

# Notifier Skill

Allows agents to send notifications to external channels (Slack, Discord, Feishu/Lark etc.) via Webhooks.

## Usage

Ensure `CLAUDE_WEBHOOK_URL` is set in your environment or `.env` file.

### Supported Channels

- **Slack / Discord**: Uses standard `{"text": "..."}` payload.
- **Feishu / Lark**: Automatically detected via URL (contains `feishu.cn` or `larksuite.com`), uses `{"msg_type": "text", "content": {"text": "..."}}`.

### Command

```bash
/Applications/ServBay/script/alias/node /Users/admin/claude-code-notification/src/index.js --type info --title 'Claude Code' --message 'Message content here'
```
