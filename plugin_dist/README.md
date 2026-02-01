# Fin Claude Plugin

Enterprise-grade development framework for Claude Code, featuring specialized agents and workflows.

## Features

- **Specialized Agents**: Architect, Code Reviewer, Security Auditor, Test Validator
- **Workflow Commands**: TDD (`/fin:dev`), Planning (`/fin:plan`), Code Review (`/fin:review`)
- **Automated Hooks**: Go code formatting on save
- **Skills**: Changelog generator, Notifications

## Installation

### Prerequisites
- Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`)

### Install via Git Clone (Recommended)
```bash
# 1. Create plugins directory
mkdir -p .claude/plugins

# 2. Clone the plugin
git clone https://github.com/zzpwestlife/fin-claude-plugin.git .claude/plugins/fin-claude-plugin
```

### Install via NPM (if published)
```bash
claude plugin install fin-claude-plugin
```

## Usage

### Start a Design Session
```bash
/sc:design
```

### Run TDD Workflow
```bash
/fin:dev "Implement user login"
```

### Review Code
```bash
/fin:review
```

## Configuration
The plugin requires the following permissions:
- Filesystem (Read/Write)
- Network (Anthropic API, etc.)
- Shell Execution (git, make, go, python3)
