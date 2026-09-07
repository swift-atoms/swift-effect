import Effect
import Testing

extension Effect {
    @Suite
    struct `Outcomes preserve result distinctions` {
        enum Failure: Swift.Error, Hashable {
            case rejected(Int)
        }

        struct Resource: ~Copyable, Hashable {
            let value: Int
        }

        static let examples: [Effect.Outcome<Int, Failure>] = [
            .resumed(1), .resumed(2), .threw(.rejected(1)), .threw(.rejected(2)), .aborted,
        ]
    }
}

extension Effect.`Outcomes preserve result distinctions` {
    @Test(arguments: [Result<Int, Failure>.success(42), .failure(.rejected(7))])
    func `Result conversion preserves the branch and payload`(_ result: Result<Int, Failure>) {
        let outcome = Effect.Outcome(result)

        #expect(outcome.result == result)
        #expect(!outcome.isAborted)
        switch result {
        case .success(let value):
            #expect(outcome.value == value)
            #expect(outcome.error == nil)
        case .failure(let error):
            #expect(outcome.value == nil)
            #expect(outcome.error == error)
        }
    }

    @Test
    func `Aborted outcomes expose neither a result nor either payload`() {
        let outcome: Effect.Outcome<Int, Self.Failure> = .aborted

        #expect(outcome.isAborted)
        #expect(outcome.result == nil)
        #expect(outcome.value == nil)
        #expect(outcome.error == nil)
    }

    @Test(arguments: 0..<5, 0..<5)
    func `Equality distinguishes every case and payload`(_ left: Int, _ right: Int) {
        #expect((Self.examples[left] == Self.examples[right]) == (left == right))
    }

    @Test
    func `Equal outcomes have equal hashes and collapse in a set`() {
        for outcome in Self.examples {
            let equal = outcome
            var first = Hasher()
            var second = Hasher()
            outcome.hash(into: &first)
            equal.hash(into: &second)
            #expect(first.finalize() == second.finalize())
        }

        #expect(Set(Self.examples + Self.examples).count == Self.examples.count)
    }

    @Test
    func `Equality and hashing borrow noncopyable outcomes`() {
        let first: Effect.Outcome<Self.Resource, Self.Failure> = .resumed(Self.Resource(value: 42))
        let equal: Effect.Outcome<Self.Resource, Self.Failure> = .resumed(Self.Resource(value: 42))
        let different: Effect.Outcome<Self.Resource, Self.Failure> = .resumed(Self.Resource(value: 43))
        let failure: Effect.Outcome<Self.Resource, Self.Failure> = .threw(.rejected(7))
        let aborted: Effect.Outcome<Self.Resource, Self.Failure> = .aborted

        let matches = first == equal
        let differs = first != different && first != failure && failure != aborted
        #expect(matches)
        #expect(differs)
        let firstIsAborted = first.isAborted
        let abortedIsAborted = aborted.isAborted
        #expect(!firstIsAborted)
        #expect(abortedIsAborted)

        var firstHasher = Hasher()
        var equalHasher = Hasher()
        first.hash(into: &firstHasher)
        equal.hash(into: &equalHasher)
        #expect(firstHasher.finalize() == equalHasher.finalize())

        switch consume first {
        case .resumed(let resource):
            let value = resource.value
            #expect(value == 42)
        case .threw: Issue.record("Expected the retained value")
        case .aborted: Issue.record("Expected the retained value")
        }
    }
}
