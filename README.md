# swift-effect

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Algebraic-effect primitives — effect declarations, resumable continuations, handlers, and handling outcomes — where one-shot continuations are `~Copyable` so exactly-once resumption is checked at compile time.

---

## Key Features

- **Effect declarations** — Conform a type to `Effect.\`Protocol\``; it carries typed `Arguments`, `Value`, and `Failure`, with `Void` arguments and `Never` failure defaulted.
- **One-shot continuations** — `Effect.Continuation.One` is `~Copyable`, so the compiler rejects both a second `resume` and a forgotten one.
- **Multi-shot continuations** — `Effect.Continuation.Multi` resumes repeatedly, supporting backtracking and non-deterministic control flow.
- **Linear resources end to end** — Effects, handlers, continuations, and outcomes admit `~Copyable` `Value` and `Arguments`, so owning resources pass through without being copied.
- **Handling outcomes** — `Effect.Outcome` records whether a handler resumed, threw, or aborted, with intrinsic `Result`, value, error, and abortion conveniences.

---

## Quick Start

A handler must resume its continuation exactly once. Because `Effect.Continuation.One` is `~Copyable`, a second `resume` — or a forgotten one — is a compile error instead of a runtime bug:

```swift
import Effect

// An operation the surrounding computation cannot satisfy on its own.
struct ReadConfig: Effect.`Protocol` {
    typealias Value = String
}

// A handler interprets the effect and resumes the one-shot continuation.
struct StaticConfig: Effect.Handler.Sync {
    typealias Handled = ReadConfig
    let stored: String

    func handle(
        _ effect: ReadConfig,
        continuation: consuming Effect.Continuation.One<String, Never>
    ) async {
        await continuation.resume(returning: stored)
        // await continuation.resume(returning: stored)  // won't compile: One is ~Copyable
    }
}

let handler = StaticConfig(stored: "production")
let continuation = Effect.Continuation.one { (result: Result<String, Never>) async in
    if case .success(let config) = result { print("config: \(config)") }
}
await handler.handle(ReadConfig(), continuation: continuation)
```

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-atoms/swift-effect.git", branch: "main")
]
```

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Effect", package: "swift-effect")
    ]
)
```

Requires Swift 6.3.1. Platform minimums: macOS 26, iOS 26, tvOS 26, watchOS 26, visionOS 26.

---

## Architecture

One library product over a single source module.

| Product | When to import |
|---------|----------------|
| `Effect` | Declaring effects, handlers, continuations, and outcomes in library or application code. |

Key types in the `Effect` namespace:

| Type | Purpose |
|------|---------|
| `Effect.\`Protocol\`` | Declares an effect operation with typed `Arguments`, `Value`, and `Failure`. |
| `Effect.Handler.\`Protocol\`` / `Effect.Handler.Sync` | Interprets an effect, receiving the effect and a one-shot continuation. |
| `Effect.Continuation.One` | `~Copyable` one-shot continuation; exactly-once resumption is compiler-enforced. |
| `Effect.Continuation.Multi` | Multi-shot continuation for backtracking and non-deterministic branches. |
| `Effect.Outcome` | Captures whether a handler resumed, threw, or aborted. |

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public release.*
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE](LICENSE.md).
