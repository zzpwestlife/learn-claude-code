# BDD Specifications: Claude Code Health Check

<!-- INPUT: Phase 1 需求 + 子 Agent 2 研究结果 -->
<!-- OUTPUT: Gherkin 场景，供 TDD 实现阶段消费 -->
<!-- POS: docs/plans/2026-03-18-health-check-design/bdd-specs.md -->

## Feature: Claude Code Environment Health Check

**As a** developer setting up or debugging Claude Code
**I want** a diagnostic tool that checks my local environment
**So that** I can quickly identify and fix configuration issues

---

## Scenario Group 1: Claude CLI Validation

```gherkin
Scenario: Claude CLI is installed and meets minimum version
  Given the developer runs `/health-check`
  When `claude --version` exits with code 0
  Then output "✅  Claude CLI    claude 1.2.3"

Scenario: Claude CLI is not installed
  Given `claude` is not in PATH
  When the CLI checker runs
  Then output "❌  Claude CLI    command not found"
  And fix_cmd is "Install from https://claude.ai/download"
```

## Scenario Group 2: API Key Validation

```gherkin
Scenario: API Key is set and valid
  Given ANTHROPIC_API_KEY is configured in environment
  When the checker pings api.anthropic.com with masked key display
  Then output "✅  API Key       Authenticated (sk-an...xxxx)"
  And the full API key value is NEVER written to stdout or logs

Scenario: API Key is set but invalid (401)
  Given ANTHROPIC_API_KEY contains an expired key
  When the checker receives HTTP 401 from Anthropic
  Then output "❌  API Key       Unauthorized (401)"
  And fix_cmd is "Update ANTHROPIC_API_KEY in your shell profile"

Scenario: API Key environment variable is not set
  Given ANTHROPIC_API_KEY is not in environment
  When the checker runs
  Then output "❌  API Key       ANTHROPIC_API_KEY not set"

Scenario: API Key is set to empty string
  Given ANTHROPIC_API_KEY="" (set but empty)
  When the checker runs
  Then output "❌  API Key       ANTHROPIC_API_KEY is empty"
  And fix_cmd is "Set ANTHROPIC_API_KEY to a valid key in your shell profile"
```

## Scenario Group 3: Dependency Toolchain

```gherkin
Scenario: All required tools present and version-compliant
  Given node ≥ 18, python3 ≥ 3.10, git are in PATH
  When deps checker runs
  Then output "✅  Toolchain     node 20.x, python3 3.11, git 2.39"

Scenario: Node.js version is outdated
  Given node 16.x is installed
  When deps checker runs
  Then output "⚠️  Toolchain     node v16 (recommend ≥ 18)"

Scenario: git is not installed
  Given git is not in PATH
  When deps checker runs
  Then output "❌  Toolchain     git: command not found"
  And fix_cmd is "Install git from https://git-scm.com"
```

## Scenario Group 4: Project Configuration

```gherkin
Scenario: All required .claude/ files are present
  Given .claude/settings.json, AGENTS.md, and constitution/ exist
  When project config checker runs
  Then output "✅  Project Config  All required files present"

Scenario: settings.json is missing
  Given .claude/settings.json does not exist
  When project config checker runs
  Then output "❌  Project Config  settings.json missing"
  And fix_cmd offers to create from template
```

## Scenario Group 5: MCP Services

```gherkin
Scenario: MCP server is reachable
  Given settings.json declares an mcpServers entry with a valid URL
  When the MCP checker performs TCP/HTTP probe within 10s
  Then output "✅  MCP Services  all 2 servers reachable"

Scenario: MCP server connection refused
  Given mcpServers includes a server that is not running
  When TCP probe fails with connection refused
  Then output "❌  MCP Services  anthropic-mcp: connection refused"

Scenario: mcpServers field is empty or absent
  Given settings.json exists but mcpServers is {} or []
  When the MCP checker runs
  Then output "⚠️  MCP Services  no MCP servers configured (skipped)"
  And status is WARN, not FAIL
```

## Scenario Group 6: Hooks Syntax

```gherkin
Scenario: All hook scripts are valid and executable
  Given .claude/hooks/ contains 3 bash scripts with correct permissions
  When bash --norc -n validates each script
  Then output "✅  Hooks         3 scripts, all valid"

Scenario: A hook script has syntax error
  Given format-go-code.sh has a syntax error on line 12
  When bash --norc -n detects the error
  Then output "❌  Hooks         format-go-code.sh: syntax error at line 12"

Scenario: A hook script is not executable
  Given pre-commit.sh has permission 644 (not executable)
  When os.access check fails
  Then output "⚠️   Hooks         pre-commit.sh: not executable"
  And fix_cmd is "chmod +x .claude/hooks/pre-commit.sh"
```

## Scenario Group 7: Skills Integrity

```gherkin
Scenario: All skills have valid frontmatter
  Given all .md files in .claude/skills/ have name and description fields
  When skills checker validates frontmatter
  Then output "✅  Skills        12 skills, all valid"

Scenario: A skill is missing required frontmatter field
  Given my-skill/SKILL.md is missing the 'description' field
  When frontmatter parser runs
  Then output "❌  Skills        my-skill/SKILL.md: missing 'description'"

Scenario: Skills directory is empty
  Given .claude/skills/ exists but contains no .md files
  When skills checker runs
  Then output "⚠️  Skills        no skill files found (skipped)"
  And status is WARN, not FAIL
```

## Scenario Group 8: Semi-Automated Repair

```gherkin
Scenario: User confirms fix for a fixable issue
  Given health check reports "⚠️ Hooks: pre-commit.sh not executable"
  When user answers "Y" to the TUI repair prompt
  Then execute "chmod +x .claude/hooks/pre-commit.sh"
  And re-run that checker
  And output "✅  Fixed: Hooks permission restored"

Scenario: User declines repair
  Given health check reports a fixable issue
  When user answers "n" to the TUI repair prompt
  Then skip execution and exit with appropriate exit code
```

## Scenario Group 9: Global Summary

```gherkin
Scenario: All checks pass
  Given all 7 checkers return PASS
  When summary is rendered
  Then output "Result: 7 Passed, 0 Warnings, 0 Failed"
  And process exits with code 0

Scenario: Mix of results
  Given 4 PASS, 1 WARN, 2 FAIL
  When summary is rendered
  Then output "Result: 4 Passed, 1 Warning, 2 Failed"
  And process exits with code 2

Scenario: Timeout on external command
  Given an MCP server probe takes > 10 seconds
  When subprocess timeout fires
  Then output "⚠️   MCP Services  timeout after 10s"
  And checker continues to next item without blocking
```
