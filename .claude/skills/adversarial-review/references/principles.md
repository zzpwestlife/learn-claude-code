# Core Engineering Principles

## Skepticism

1.  **Assume Failure**: Every line of code can fail. Validate inputs, handle exceptions, and log errors.
2.  **Test First**: If it's not tested, it's broken.
3.  **Trust No One**: External services, user input, and even internal APIs are untrusted.
4.  **Simplicity**: Complexity breeds bugs. Prefer simple, explicit logic over clever tricks.
5.  **Performance**: Code should be fast enough, but correctness comes first.

## Architecture

1.  **Separation of Concerns**: Each module should have a single responsibility.
2.  **Loose Coupling**: Minimize dependencies between modules. Use interfaces, not implementations.
3.  **Data Flow**: Data should flow in a clear, predictable direction. Avoid circular dependencies.
4.  **Extensibility**: Design for change, but don't over-engineer for hypothetical futures (YAGNI).
5.  **Consistency**: Follow established patterns and conventions. Don't reinvent the wheel.

## Minimalism

1.  **Less is More**: Every line of code is a liability. Delete code whenever possible.
2.  **YAGNI (You Aren't Gonna Need It)**: Don't implement features you *might* need later. Wait until you *actually* need them.
3.  **KISS (Keep It Simple, Stupid)**: Avoid unnecessary abstraction.
4.  **Readability**: Code is read more often than it is written. Write for humans, not computers.
5.  **Avoid Premature Optimization**: Optimize only when you have data proving a bottleneck.
