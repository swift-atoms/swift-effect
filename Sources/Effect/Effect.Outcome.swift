extension Effect {

    public enum Outcome<Value: ~Copyable, Failure: Swift.Error>: ~Copyable {

        case resumed(Value)

        case threw(Failure)

        case aborted
    }
}

extension Effect.Outcome: Swift.Copyable where Value: Swift.Copyable {}

extension Effect.Outcome: Swift.Sendable where Value: Swift.Sendable & ~Copyable, Failure: Swift.Sendable {}

extension Effect.Outcome where Value: Copyable {

    public init(_ result: Result<Value, Failure>) {
        switch result {
        case .success(let value):
            self = .resumed(value)

        case .failure(let error):
            self = .threw(error)
        }
    }

    public var result: Result<Value, Failure>? {
        switch self {
        case .resumed(let value):
            return .success(value)

        case .threw(let error):
            return .failure(error)

        case .aborted:
            return nil
        }
    }
}

extension Effect.Outcome where Value: Copyable {

    public var value: Value? {
        if case .resumed(let value) = self {
            return value
        }
        return nil
    }

    public var error: Failure? {
        if case .threw(let error) = self {
            return error
        }
        return nil
    }
}

extension Effect.Outcome where Value: ~Copyable {

    public var isAborted: Bool {
        switch self {
        case .aborted: return true
        case .resumed: return false
        case .threw: return false
        }
    }
}
