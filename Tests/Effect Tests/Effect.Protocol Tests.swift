import Effect
import Testing

extension Effect {
    @Suite
    struct `Effects describe handler requests` {
        struct Ping: Effect.`Protocol` {
            typealias Value = String
        }

        struct PingHandler: Effect.Handler.`Protocol` {
            typealias Handled = Ping

            func handle(
                _ effect: borrowing Ping,
                continuation: consuming Effect.Continuation.One<String, Never>
            ) async {
                let _: Void = effect.arguments
                await continuation.resume(returning: "pong")
            }
        }

        struct Addition: Effect.`Protocol` {
            typealias Arguments = (left: Int, right: Int)
            typealias Value = Int

            enum Failure: Swift.Error, Equatable {
                case negativeInput(Int)
            }

            let left: Int
            let right: Int

            var arguments: Arguments { (left, right) }
        }

        struct Handler: Effect.Handler.`Protocol` {
            typealias Handled = Addition

            func handle(
                _ effect: borrowing Addition,
                continuation: consuming Effect.Continuation.One<Int, Addition.Failure>
            ) async {
                if effect.left < 0 {
                    await continuation.resume(throwing: .negativeInput(effect.left))
                } else {
                    await continuation.resume(returning: effect.left + effect.right)
                }
            }
        }

        static func handle<H: Effect.Handler.`Protocol`>(
            _ effect: borrowing H.Handled,
            using handler: borrowing H,
            continuation: consuming Effect.Continuation.One<H.Handled.Value, H.Handled.Failure>
        ) async {
            await handler.handle(effect, continuation: continuation)
        }

        static func arguments<E: Effect.`Protocol`>(_ effect: borrowing E) -> E.Arguments
        where E.Arguments: Copyable {
            effect.arguments
        }
    }
}

extension Effect.`Effects describe handler requests` {
    @Test
    func `A handler accepts default void arguments and an infallible result`() async {
        let results = Effect.`Continuations deliver results`.Recorder<String>()
        let continuation = Effect.Continuation.one { (result: Result<String, Never>) async in
            switch result {
            case .success(let value): await results.append(value)
            }
        }

        await Self.handle(Self.Ping(), using: Self.PingHandler(), continuation: continuation)

        #expect(await results.values == ["pong"])
    }

    @Test
    func `Generic argument access preserves the request fields`() {
        let request = Self.Addition(left: 10, right: 20)
        let arguments = Self.arguments(request)

        #expect(arguments.left == 10)
        #expect(arguments.right == 20)
    }

    @Test(arguments: [10, -10])
    func `Generic handler dispatch delivers the declared value or typed failure`(_ left: Int) async {
        let results = Effect.`Continuations deliver results`.Recorder<Result<Int, Self.Addition.Failure>>()
        let continuation = Effect.Continuation.one { (result: Result<Int, Self.Addition.Failure>) async in
            await results.append(result)
        }

        await Self.handle(
            Self.Addition(left: left, right: 20),
            using: Self.Handler(),
            continuation: continuation
        )

        let expected: Result<Int, Self.Addition.Failure> = left < 0
            ? .failure(.negativeInput(left))
            : .success(left + 20)
        #expect(await results.values == [expected])
    }
}
