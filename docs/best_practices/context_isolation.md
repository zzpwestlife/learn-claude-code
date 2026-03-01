# Context Isolation: The "AI Flow State" Strategy

> **Core Principle**: Do not pollute the global user context with project-specific tools or rules. Keep the AI's "working memory" clean and focused.

## 1. The Myth of "Global Convenience"

Many developers intuitively add their favorite MCP servers (like GitHub, Linear, PostgreSQL) or custom skills to their **User-Level Configuration** (e.g., `~/.claude/CLAUDE.md` or global MCP settings), thinking: *"I want these tools available everywhere."*

**This is an anti-pattern.**

### Why Global Config Hurts Performance
1.  **Token Pollution**: Every global tool definition consumes tokens in *every* session, even if irrelevant.
2.  **Context Confusion**: If you have a global `java-linter` but are working in a `python` project, the AI has to waste inference cycles ignoring the Java tools.
3.  **Dependency Hell**: Global tools may conflict with project-specific versions or requirements.

## 2. The "AI Flow State"

Just as a human developer enters a "Flow State" by eliminating distractions (notifications, noise), an AI Agent performs best when its context window contains **only** what is necessary for the current project.

**The "Flow State" Setup:**
- **User Level (`~/.claude/`)**: EMPTY or minimal (only universal OS-level utilities).
- **Project Level (`./.claude/`)**: RICH and SPECIFIC. Contains all the rules, styles, and tools for *this specific domain*.

## 3. Implementation Strategy

### ❌ Bad Practice (Global Stuffing)
Putting everything in your home directory:
```
~/.claude/config.json
{
  "mcpServers": {
    "github": { ... },
    "postgres": { ... },   <-- Irrelevant for a static site
    "linear": { ... }      <-- Irrelevant for a personal script
  }
}
```

### ✅ Best Practice (Project Isolation)
Define dependencies explicitly in the project:

**Project A (Web App)**:
```
./.claude/CLAUDE.md
@./skills/react-component-gen.md
@./mcp/postgres-connector.json
```

**Project B (Data Science)**:
```
./.claude/CLAUDE.md
@./skills/pandas-helper.md
@./mcp/jupyter-bridge.json
```

## 4. Benefits of Isolation

| Feature | Global Config | Project Isolation |
| :--- | :--- | :--- |
| **Startup Cost** | High (Loads everything) | Low (Loads only needed) |
| **Accuracy** | Lower (Distracted by irrelevant tools) | **Higher** (Focused context) |
| **Portability** | Zero (Config lives on your machine) | **100%** (Config lives in the repo) |
| **Team Sync** | Hard ("It works on my machine") | **Easy** (Everyone uses repo config) |

## 5. Recommendation

**Treat your User-Level Config like the Root User**: Use it sparingly, only for system-wide administration.
**Treat your Project-Level Config like a Docker Container**: Self-contained, reproducible, and minimal.

> **Rule of Thumb**: If a tool is not used in >90% of your projects, it belongs in the Project Config, not the User Config.
