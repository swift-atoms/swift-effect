public protocol __EffectProtocol: ~Copyable, SendableMetatype {

    associatedtype Arguments: ~Copyable = Void

    associatedtype Value: ~Copyable

    associatedtype Failure: Swift::Error = Never

    var arguments: Arguments { borrowing get }
}

extension __EffectProtocol where Self: ~Copyable, Arguments == Void {

    public var arguments: Void { () }
}
