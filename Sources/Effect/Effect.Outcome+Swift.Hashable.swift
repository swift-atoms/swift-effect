extension Effect.Outcome: Swift.Hashable
where Value: Swift.Hashable & ~Copyable, Failure: Swift.Hashable {

    public borrowing func hash(into hasher: inout Hasher) {
        switch self {
        case .resumed(let value):
            hasher.combine(0)
            value.hash(into: &hasher)

        case .threw(let error):
            hasher.combine(1)
            error.hash(into: &hasher)

        case .aborted:
            hasher.combine(2)
        }
    }
}
