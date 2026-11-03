# swift-effect

Use this package when code should describe a request (an effect) and leave answering it to a handler chosen elsewhere: conform the request to `Effect.Protocol`, answer it with an `Effect.Handler.Protocol`, and deliver the answer through `Effect.Continuation.One` (exactly once) or `Effect.Continuation.Multi` (any number of times). Record what a delivery produced with `Effect.Outcome`. With the `Dependency` trait, `Effect.Context` scopes handler values; it is a thin alias over swift-dependency, so use that package directly when you only need scoped values and no effects.

## Laws

- Every `resume` awaits its callback: when the call returns, delivery has finished.
- Dropping an `Effect.Continuation.One` without resuming it invokes nothing and releases what its callbacks captured; resuming it releases them after the callback returns.
- `onResume` runs its observer to completion before forwarding the same result to the wrapped continuation; when stacked, the outermost observer runs first and the original delivery last. Dropping a decorated continuation runs neither observers nor delivery.
- Every copy of an `Effect.Continuation.Multi` calls the same callback, once per `resume`. Sequential awaited calls arrive in call order, concurrent calls each arrive exactly once in no defined order, and a failure does not end the continuation.
- `Effect.Outcome.aborted` carries no result: `result`, `value` and `error` are all `nil`. For the other cases, `Effect.Outcome(_:)` and `result` round-trip a `Swift.Result`.
- Two `Effect.Outcome` values are equal only when case and payload are equal, and equal outcomes hash equally.
- `Effect.Context.with` overrides values for the duration of the operation only, including across suspension points; nested scopes override outer ones and the outer value returns when the inner scope ends. A key never set reads its `liveValue`, or its `testValue` when `isTestContext` is set (falling back to `liveValue`); an explicitly set value overrides both.
