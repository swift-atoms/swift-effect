#if Dependency
    public import Dependency

    public protocol __EffectHandled: __EffectProtocol {

        associatedtype HandlerKey: Dependency.Key
        where HandlerKey.Value: Effect.Handler.`Protocol`, HandlerKey.Value.Handled == Self
    }

    extension Effect {

        public typealias Handled = __EffectHandled
    }
#endif
