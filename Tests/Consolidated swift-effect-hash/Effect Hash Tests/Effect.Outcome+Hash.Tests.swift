import Effect
import Hash
import Testing

@testable import Effect

private struct Value: Hash::Hash.`Protocol` {}
private struct Failure: Swift.Error, Hash::Hash.`Protocol` {}

@Suite
struct `Effect.Outcome Hash Tests` {

    @Test
    func `Outcome supplies Hash's domain-typed value`() {
        let a: Effect::Effect.Outcome<Value, Failure> = .resumed(Value())
        let b: Effect::Effect.Outcome<Value, Failure> = .resumed(Value())

        let first: Hash::Hash.Value = hash(a)
        let second: Hash::Hash.Value = hash(b)
        #expect(first == second)
    }

    @Test
    func `Outcome is natively hashable through the seam`() {
        let resumed: Effect::Effect.Outcome<Value, Failure> = .resumed(Value())
        let equal: Effect::Effect.Outcome<Value, Failure> = .resumed(Value())
        let aborted: Effect::Effect.Outcome<Value, Failure> = .aborted

        let outcomes: Set<Effect::Effect.Outcome<Value, Failure>> = [resumed, equal, aborted]
        #expect(outcomes.count == 2)
    }
}

private func hash<T: Hash::Hash.`Protocol`>(_ value: borrowing T) -> Hash::Hash.Value {
    value.hashValue
}
