# Adversarial Review Command

Invoke the adversarial review process to challenge your code with heterogeneous agents.

## Usage

```bash
/adversarial-review <files...> -i "<intent>"
```

## Description

Spawns independent reviewer processes (Skeptic, Architect, Minimalist) to attack your code.
- **Skeptic**: Finds bugs & security issues.
- **Architect**: Checks system design.
- **Minimalist**: Checks simplicity.

## Examples

```bash
# Review a single file
/adversarial-review src/main.py -i "Add user authentication"

# Review multiple files
/adversarial-review src/auth.py src/user.py -i "Refactor user model"
```

## Implementation

- **Script**: `.claude/skills/adversarial-review/scripts/adversarial_review.py`
- **Command**: Wraps the python execution of the script.

## Command Definition

To register this command in Claude Code, ensure this file is placed in `.claude/commands/`.
When you type `/adversarial-review`, Claude Code will look for this definition and execute the underlying tool.

Note: Since this is a custom tool implementation, the actual execution is handled by the `RunCommand` tool invoking the python script.

**System Instruction:**
When the user types `/adversarial-review`, you should execute:
`python3 .claude/skills/adversarial-review/scripts/adversarial_review.py <args>`
