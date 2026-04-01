# Design Patterns — Agent Quick Reference

> For agents choosing code structure patterns. Focus: what problem each solves, when to use/avoid.

## Creational Patterns

### Factory (+ Abstract Factory)
**Solves:** Client code shouldn't know which concrete class to instantiate.
**Use when:** Object creation logic is complex or varies by context (e.g., platform-specific UI).
**Don't use when:** Only one concrete type exists — just call the constructor.
**Structure:** Client calls `Factory.create(type)` → Factory returns a subclass instance.

### Singleton
**Solves:** Exactly one instance needed globally (config, connection pool, logger).
**Use when:** Shared resource that's expensive to create and must be coordinated.
**Don't use when:** You're using it as a global variable — prefer dependency injection instead.
**Structure:** Class has private constructor + static `getInstance()` that lazily creates/returns the single instance.

### Builder
**Solves:** Constructing complex objects step-by-step without telescoping constructors.
**Use when:** Object has many optional parameters or multiple valid configurations.
**Don't use when:** Object has few, required fields — a simple constructor suffices.
**Structure:** `Builder` accumulates parameters via chained methods → `.build()` returns the final object.

## Structural Patterns

### Adapter
**Solves:** Make incompatible interfaces work together.
**Use when:** Integrating a third-party library or legacy code with a different interface.
**Don't use when:** You control both sides — just change one interface.
**Structure:** Adapter wraps Adaptee, translating calls from the target interface to the adaptee's interface.

### Decorator
**Solves:** Add behavior to objects dynamically without modifying their class.
**Use when:** You need composable, stackable enhancements (logging + caching + auth on a service).
**Don't use when:** One fixed enhancement — just extend the class or use a wrapper function.
**Structure:** Decorator implements the same interface as the wrapped object, delegates calls and adds behavior.

### Facade
**Solves:** Simplify access to a complex subsystem.
**Use when:** Clients need a simple interface to a multi-step or multi-class operation.
**Don't use when:** The subsystem is already simple, or clients need fine-grained control.
**Structure:** Facade provides high-level methods that orchestrate calls to subsystem classes.

### Repository
**Solves:** Decouple data access logic from business logic.
**Use when:** Business code shouldn't know whether data comes from DB, API, or cache.
**Don't use when:** Simple scripts or prototypes with one data source.
**Structure:** Repository interface defines `find/save/delete` → concrete implementations handle the storage layer.

## Behavioral Patterns

### Observer
**Solves:** Notify multiple objects when state changes without tight coupling.
**Use when:** Event systems, UI updates, pub/sub within a process.
**Don't use when:** Only one listener — a direct callback is simpler.
**Structure:** Subject maintains a list of observers → calls `observer.update()` on state change.

### Strategy
**Solves:** Swap algorithms at runtime without changing client code.
**Use when:** Multiple ways to do the same thing (sorting, validation, pricing rules).
**Don't use when:** Only one algorithm — just inline it.
**Structure:** Client holds a Strategy interface reference → concrete strategies implement the algorithm.

### Command
**Solves:** Encapsulate a request as an object for queuing, undo, or logging.
**Use when:** Undo/redo, task queues, macro recording, deferred execution.
**Don't use when:** Simple direct calls with no need for history or queuing.
**Structure:** Command object has `execute()` (and optionally `undo()`) → invoker calls `command.execute()`.

### Dependency Injection (DI)
**Solves:** Remove hard-coded dependencies so classes are testable and configurable.
**Use when:** Classes depend on services that may vary (DB, API client, logger).
**Don't use when:** No external dependencies or tests — over-engineering.
**Structure:** Dependencies are passed in via constructor/setter rather than created internally.

## Pattern Selection Guide

| Situation | Pattern |
|-----------|---------|
| Need to create objects without specifying exact class | Factory |
| Need exactly one shared instance | Singleton (or better: DI with singleton scope) |
| Wrapping incompatible third-party code | Adapter |
| Adding optional behaviors to objects | Decorator |
| Simplifying a complex API | Facade |
| Reacting to state changes | Observer |
| Swapping algorithms | Strategy |
| Undo/redo, task queues | Command |
| Isolating data access | Repository |
| Testable, loosely-coupled dependencies | Dependency Injection |

## Anti-Pattern Warnings

- **Singleton abuse:** If you have many singletons, you have hidden global state. Use DI.
- **Pattern overuse:** Three similar lines > premature abstraction. Add patterns when complexity demands it, not preemptively.
- **Wrong pattern:** Strategy for one algorithm, Observer for one listener, Factory for one type — all add indirection without benefit.
