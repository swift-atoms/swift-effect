import Effect
import Equation
import Testing

@testable import Effect

@Suite
struct `Effect.Outcome Equation Tests` {

    @Test
    func `equatable for resumed`() {
        let a: Effect::Effect.Outcome<Int, Never> = .resumed(1)
        let b: Effect::Effect.Outcome<Int, Never> = .resumed(1)
        let c: Effect::Effect.Outcome<Int, Never> = .resumed(2)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `equatable for threw`() {
        struct E: Swift.Error, Equatable {
            let code: Int
        }

        let a: Effect::Effect.Outcome<Int, E> = .threw(E(code: 1))
        let b: Effect::Effect.Outcome<Int, E> = .threw(E(code: 1))
        let c: Effect::Effect.Outcome<Int, E> = .threw(E(code: 2))

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `equatable for aborted`() {
        let a: Effect::Effect.Outcome<Int, Never> = .aborted
        let b: Effect::Effect.Outcome<Int, Never> = .aborted

        #expect(a == b)
    }

    @Test
    func `different cases not equal`() {
        struct E: Swift.Error, Equatable {}

        let resumed: Effect::Effect.Outcome<Int, E> = .resumed(1)
        let threw: Effect::Effect.Outcome<Int, E> = .threw(E())
        let aborted: Effect::Effect.Outcome<Int, E> = .aborted

        #expect(resumed != threw)
        #expect(resumed != aborted)
        #expect(threw != aborted)
    }
}
