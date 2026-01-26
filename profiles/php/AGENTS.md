# Commands

- **Build/Install**: `composer install`
- **Test**: `vendor/bin/phpunit`
- **Lint**: `vendor/bin/phpcs` (if available)
- **Format**: `vendor/bin/php-cs-fixer fix` (if available)
- **Serve**: `php -S localhost:8000 -t public`
*Note: Check `composer.json` > `scripts` for project-specific commands.*

# Guidelines

> **⚠️ Constitution**: This project strictly adheres to [constitution.md](constitution.md).
> All code changes MUST comply with its **11 Core Principles** and relevant **Language Annexes** (e.g., [PHP Annex](docs/constitution/php_annex.md)).

## Git & Version Control
- **Commit Message**: **[Strictly Follow]** Conventional Commits (type(scope): subject).
  - Format: `<type>(<scope>): <subject>`
  - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.

## Workflow (4-Phase)
1. **Research**: Analyze context & patterns. **Review First**: Before coding, use `@` to read relevant code (Controllers, Services, Models).
2. **Plan**: Create a step-by-step plan using the **Plan Template** below. **Wait for confirmation**. Include **Verification Steps**.
3. **Implement**: Write code + tests. No `TODO`s.
4. **Verify**: Run tests (`phpunit`) and Lint. Fix root causes.

## Plan Template (Mandatory)
When creating a plan, you **MUST** include the following "Constitution Check" section:

```markdown
## Constitution Check (合宪性审查)
*GATE: Must pass before technical design.*

- [ ] **Simplicity (Art. 1):** Is the framework used effectively? Is over-abstraction avoided?
- [ ] **Test First (Art. 2):** Does the plan include writing tests *before* implementation?
- [ ] **Clarity (Art. 3):** Are exceptions explicitly handled? No implicit global state?
- [ ] **Core Logic (Art. 4):** Is business logic in Services, decoupled from Controllers?
- [ ] **Security (Art. 11):** Are inputs validated? No sensitive data leakage?

*If any check fails, provide a strong justification in the "Complexity Tracking" section.*
```

## AI Collaboration Directives
- **Framework First**: Prioritize Lumen/Laravel built-in features (Service Container, Eloquent, Middleware) over custom implementations.
- **PSR Compliance**: Code MUST follow PSR-12 coding standards.
- **Dependency Injection**: Always use Constructor Injection for dependencies. NEVER use `new` in business logic.
- **Type Safety**: Use PHP 7+ type hinting (scalar types, return types) where possible. Use PHPDoc for unsupported types.

## Verification First
> **"Start with how you'll prove it's right."**
- **Code**: Provide input/output examples and pass unit tests.
- **Refactor**: Ensure tests pass before and after.

## Code Style & Patterns
- **Core**: Follow [constitution.md](constitution.md) Principles.
- **PHP**: See [PHP Annex](docs/constitution/php_annex.md).
- **Architecture**:
  - **Controller**: Request/Response only. No business logic.
  - **Service**: Business logic.
  - **Model**: Eloquent definitions only.
