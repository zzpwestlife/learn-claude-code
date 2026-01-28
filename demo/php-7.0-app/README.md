# PHP 7.0 Compatibility Demo

This project demonstrates strict compliance with PHP 7.0 standards as defined in `docs/constitution/php_annex.md`.

## Requirements
- PHP ^7.0 (Syntax compatible with 7.0)
- Composer

## Compatibility Checks
- `composer.json` requires PHP `^7.0` (runs on 7.0, 7.1, etc.), but code syntax is strictly 7.0.
- Uses PHP 7.0 features:
  - Scalar type hints (`int`, `float`, `string`)
  - Return type hints (`: int`)
  - Null coalescing operator (`??`)
  - Spaceship operator (`<=>`)
  - Strict types (`declare(strict_types=1)`)
- Avoids PHP 7.1+ features (Enforced by PHPCS):
  - No nullable types (`?string`) - uses default `null` value instead
  - No void return type (`: void`)
  - No `iterable` type
  - No class constant visibility modifiers


## Running Tests
Use Docker to verify PHP 7.0 compatibility:

```bash
cd demo/php-7.0-app
docker build -t php70-demo .
docker run --rm php70-demo
```
