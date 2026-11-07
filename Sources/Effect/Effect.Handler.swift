extension Effect {

    public enum Handler {

        public typealias `Protocol` = __EffectHandler
    }
}

extension Effect.Handler {

    public typealias Sync = __EffectHandler
}
