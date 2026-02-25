# Commands

- **Build/Install**: `composer install`
- **Test**: `vendor/bin/phpunit`
- **Lint**: `vendor/bin/phpcs` (if available)
- **Format**: `vendor/bin/php-cs-fixer fix` (if available)
- **Serve**: `php -S localhost:8000 -t public`
*Note: Check `composer.json` `scripts` for project-specific commands.*

# Guidelines

> **⚠️ Constitution**: This project strictly follows [constitution.md](../../constitution.md).
> All code modifications must comply with its **11 core principles** and relevant **language annexes** (e.g., [PHP Annex](../../.claude/constitution/php_annex.md)).

## Git & Version Control
- **Commit Messages**: **[STRICT]** Conventional Commits (type(scope): subject).
  - Format: `<type>(<scope>): <subject>`
  - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.

## Workflow (Four Phases)
1. **Research**: Analyze context and patterns. **Review first**: Use `@` to read relevant code (Controllers, Services, Models) before coding.
2. **Plan**: Use the **Plan Template** below to create step-by-step plans. **Wait for confirmation**. Include **verification steps**.
3. **Implement**: Write code and tests. No `TODO`s allowed.
4. **Verify**: Run tests (`phpunit`) and Lint. Fix root causes.

## Plan Template (Mandatory)
When creating plans, you **MUST** include the following "Constitution Check" section:

```markdown
## Constitution Check
*GATE: Must pass before technical design.*

- [ ] **Simplicity (Art. 1):** Is the framework used effectively? Is over-abstraction avoided?
- [ ] **Test First (Art. 2):** Does the plan include writing tests *before* implementation?
- [ ] **Clarity (Art. 3):** Are exceptions explicitly handled? No implicit global state?
- [ ] **Core Logic (Art. 4):** Is business logic in Services, decoupled from Controllers?
- [ ] **Security (Art. 11):** Are inputs validated? No sensitive data leakage?

*If any check fails, provide a strong justification in the "Complexity Tracking" section.*
```

## AI Collaboration Guidelines
- **Framework First**: Prioritize Lumen/Laravel built-in capabilities (Service Container, Eloquent, Middleware), avoid custom implementations.
- **PSR Compliance**: Code must follow PSR-12 coding standards.
- **Dependency Injection**: Dependencies must use constructor injection. Never use `new` in business logic.
- **Type Safety**: Use PHP 7+ type annotations (scalar types, return types) whenever possible. Use PHPDoc for unsupported types.

## Verify First
> **"Start with how you'll prove it's right."**
- **Code**: Provide input/output examples and pass unit tests.
- **Refactor**: Ensure tests pass before and after refactoring.

## Code Style & Patterns
- **Core**: Follow [constitution.md](../../constitution.md) principles.
- **PHP**: See [PHP Annex](../../.claude/constitution/php_annex.md).
- **Architecture**:
  - **Controller**: Only handles request/response, no business logic.
  - **Service**: Business logic.
  - **Model**: Eloquent definitions only.
