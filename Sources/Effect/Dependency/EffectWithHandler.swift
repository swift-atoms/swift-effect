#if Dependency
    public import Dependency

    public protocol EffectWithHandler: Effect.`Protocol` {

        associatedtype HandlerKey: Dependency.Key
        where HandlerKey.Value: Effect.Handler.`Protocol`, HandlerKey.Value.Handled == Self
    }
#endif
