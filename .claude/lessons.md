# Lessons (Project Memory)

本文件用于沉淀在本仓库中反复出现的错误与对应的永久规则。

## How to Write a Lesson

使用固定格式追加一条记录：

- **Mistake**: 发生了什么
- **Impact**: 造成了什么代价
- **Rule**: 永久规则（可执行、可验证）
- **Where**: 应该加到哪里（例如 `.claude/rules/CORE_RULES.md`，或保持只在本文件）

## Lessons

### Investigation Discipline — Verify Before Asserting

- **Mistake**: Claude asserted a root cause (e.g., "broker SmsCodeSend failed") without reading the actual code path, forcing the user to push back to get the real answer (`NextSendInterval==0` was the true cause).
- **Impact**: Wasted a full back-and-forth loop; eroded trust in diagnostic output.
- **Rule**: Before stating a root cause, read the exact function body and call site in question. If the path cannot be confirmed within 2–3 file reads, surface the uncertainty explicitly ("I haven't verified the actual call — here's my hypothesis") rather than asserting as fact.
- **Where**: Enforced here; referenced in CORE_RULES §1 Evidence-Based principle.
