# Documentation Context

This context is automatically loaded when you are working in the `docs/` directory.

## 1. Documentation Standards
- **Language**: All explanations must be in **Chinese** (Simplified). Technical terms should be in **English**.
- **Format**: Standard Markdown.
  - **Headers**: Use clear hierarchy (`#`, `##`, `###`).
  - **Code Blocks**: MUST specify language identifier (e.g., `python`, `bash`, `json`).
  - **Lists**: Use bullets (`-`) or numbers (`1.`) consistently.
- **Tone**: Educational, professional, and clear. Explain the "Why" behind the "How".

## 2. Diagramming
- **Tool**: Use **Mermaid.js** for diagrams whenever possible.
- **Style**: Keep diagrams simple. Avoid overcrowding.
- **Labeling**: Use clear labels for nodes and edges.

## 3. Structure
- **README First**: Every directory should have a `README.md` explaining its purpose.
- **Links**: Use relative paths for internal links (`[Link](../path/to/file.md)`).
- **Index**: Maintain an index file (`SUMMARY.md` or similar) if documenting a complex system.

## 4. Content Guidelines
- **Prerequisites**: Clearly state what is needed before starting a guide.
- **Steps**: Numbered steps for procedures.
- **Troubleshooting**: Include a troubleshooting section for common issues.
- **Verification**: Explain how to verify that a step was successful.
