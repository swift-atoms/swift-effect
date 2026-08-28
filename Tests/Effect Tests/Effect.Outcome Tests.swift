import Effect
import Testing

@testable import Effect

@Suite
struct `Effect.Outcome Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `resumed case stores value`() {
        let outcome: Effect.Outcome<String, Never> = .resumed("hello")

        #expect(outcome.value == "hello")
        #expect(outcome.error == nil)
        #expect(!outcome.isAborted)
    }

    @Test
    func `threw case stores error`() {
        struct Failure: Swift.Error, Equatable {
            let code: Int
        }

        let outcome: Effect.Outcome<String, Failure> = .threw(Failure(code: 42))

        #expect(outcome.value == nil)
        #expect(outcome.error == Failure(code: 42))
        #expect(!outcome.isAborted)
    }

    @Test
    func `aborted case`() {
        let outcome: Effect.Outcome<String, Never> = .aborted

        #expect(outcome.value == nil)
        #expect(outcome.error == nil)
        #expect(outcome.isAborted)
    }

    @Test
    func `init from Result success`() {
        let result: Result<Int, Never> = .success(42)
        let outcome = Effect.Outcome(result)

        #expect(outcome.value == 42)
        if case .resumed(let value) = outcome {
            #expect(value == 42)
        } else {
            Issue.record("Expected resumed case")
        }
    }

    @Test
    func `init from Result failure`() {
        struct E: Swift.Error, Equatable {}

        let result: Result<Int, E> = .failure(E())
        let outcome = Effect.Outcome(result)

        if case .threw(let error) = outcome {
            #expect(error == E())
        } else {
            Issue.record("Expected threw case")
        }
    }

    @Test
    func `result property for resumed`() {
        let outcome: Effect.Outcome<String, Never> = .resumed("test")

        #expect(outcome.result == .success("test"))
    }

    @Test
    func `result property for threw`() {
        struct E: Swift.Error, Equatable {}

        let outcome: Effect.Outcome<String, E> = .threw(E())

        #expect(outcome.result == .failure(E()))
    }

    @Test
    func `result property for aborted returns nil`() {
        let outcome: Effect.Outcome<String, Never> = .aborted

        #expect(outcome.result == nil)
    }

    @Test
    func `equatable and hashable are intrinsic`() {
        enum Failure: Swift.Error, Hashable {
            case failed
        }

        let resumed: Effect.Outcome<Int, Failure> = .resumed(1)
        let equal: Effect.Outcome<Int, Failure> = .resumed(1)
        let threw: Effect.Outcome<Int, Failure> = .threw(.failed)
        let aborted: Effect.Outcome<Int, Failure> = .aborted

        #expect(resumed == equal)
        #expect(resumed != threw)
        #expect(threw != aborted)
        #expect(Set([resumed, equal, threw, aborted]).count == 3)
    }

    @Test
    func `noncopyable payload can be equated and hashed`() {
        struct Value: ~Copyable, Equatable, Hashable {
            let rawValue: Int
        }

        let lhs: Effect.Outcome<Value, Never> = .resumed(Value(rawValue: 1))
        let rhs: Effect.Outcome<Value, Never> = .resumed(Value(rawValue: 1))

        let areEqual = lhs == rhs
        #expect(areEqual)

        var lhsHasher = Hasher()
        var rhsHasher = Hasher()
        lhs.hash(into: &lhsHasher)
        rhs.hash(into: &rhsHasher)
        #expect(lhsHasher.finalize() == rhsHasher.finalize())
    }

}
