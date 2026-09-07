import Effect
import Synchronization
import Testing

extension Effect {
    @Suite
    struct `Continuations deliver results` {
        enum Failure: Swift.Error, Hashable {
            case rejected(Int)
        }

        actor Recorder<Value: Sendable> {
            private(set) var values: [Value] = []

            func append(_ value: Value) {
                values.append(value)
            }
        }

        final class Counter: Sendable {
            private let storage = Mutex(0)

            var value: Int { storage.withLock { $0 } }

            func increment() {
                storage.withLock { $0 += 1 }
            }
        }

        final class Capture: Sendable {
            let releases: Counter

            init(releases: Counter) {
                self.releases = releases
            }

            deinit { releases.increment() }
        }

        struct Resource: ~Copyable {
            let value: Int
            let releases: Counter

            deinit { releases.increment() }
        }

        final class LocalValue {
            var value: Int

            init(_ value: Int) {
                self.value = value
            }
        }

        static func deliver<C: Effect.Continuation.`Protocol` & ~Copyable>(
            _ continuation: consuming C,
            value: consuming sending C.Value
        ) async where C.Value: ~Copyable {
            await continuation.resume(returning: value)
        }

        static func fail<C: Effect.Continuation.`Protocol` & ~Copyable>(
            _ continuation: consuming C,
            error: C.Failure
        ) async where C.Value: ~Copyable {
            await continuation.resume(throwing: error)
        }

        static func retainingCapture(
            calls: Counter,
            releases: Counter
        ) -> Effect.Continuation.One<Int, Never> {
            let capture = Capture(releases: releases)
            return Effect.Continuation.one { [capture] (_: Result<Int, Never>) async in
                calls.increment()
                withExtendedLifetime(capture) {}
            }
        }

        static func discard(_ continuation: consuming Effect.Continuation.One<Int, Never>) {
            _ = consume continuation
        }
    }
}

extension Effect.`Continuations deliver results` {
    @Test
    func `One-shot protocol dispatch transfers and destroys a noncopyable value`() async {
        let values = Self.Recorder<Int>()
        let releases = Self.Counter()
        let continuation = Effect.Continuation.one(
            onValue: { (resource: consuming sending Self.Resource) async in
                await values.append(resource.value)
            },
            onError: { (_: Self.Failure) async in
                Issue.record("Unexpected failure callback")
            }
        )

        await Self.deliver(
            continuation,
            value: Self.Resource(value: 42, releases: releases)
        )

        #expect(await values.values == [42])
        #expect(releases.value == 1)
    }

    @Test
    func `One-shot protocol dispatch preserves typed failure with a noncopyable value sort`() async {
        let failures = Self.Recorder<Self.Failure>()
        let continuation = Effect.Continuation.one(
            onValue: { (_: consuming sending Self.Resource) async in
                Issue.record("Unexpected value callback")
            },
            onError: { (error: Self.Failure) async in
                await failures.append(error)
            }
        )

        await Self.fail(continuation, error: .rejected(7))

        #expect(await failures.values == [.rejected(7)])
    }

    @Test
    func `Multi-shot protocol dispatch shares delivery across consumed copies`() async {
        let results = Self.Recorder<Result<Int, Self.Failure>>()
        let continuation = Effect.Continuation.multi { (result: sending Result<Int, Self.Failure>) async in
            await results.append(result)
        }

        await Self.deliver(continuation, value: 42)
        await Self.fail(continuation, error: .rejected(7))
        await continuation.resume(returning: 43)

        #expect(await results.values == [.success(42), .failure(.rejected(7)), .success(43)])
    }
}
