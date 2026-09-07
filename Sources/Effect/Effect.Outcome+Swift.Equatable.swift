extension Effect.Outcome: Swift.Equatable
where Value: Swift.Equatable & ~Copyable, Failure: Swift.Equatable {

    public static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        switch lhs {
        case .resumed(let lhs):
            switch rhs {
            case .resumed(let rhs): return lhs == rhs
            case .threw: return false
            case .aborted: return false
            }

        case .threw(let lhs):
            switch rhs {
            case .threw(let rhs): return lhs == rhs
            case .resumed: return false
            case .aborted: return false
            }

        case .aborted:
            switch rhs {
            case .aborted: return true
            case .resumed: return false
            case .threw: return false
            }
        }
    }
}
