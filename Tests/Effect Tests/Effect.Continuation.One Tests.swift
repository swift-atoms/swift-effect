import Effect
import Testing

extension Effect.`Continuations deliver results` {
    @Test
    func `One-shot value delivery awaits its callback`() async {
        let values = Self.Recorder<String>()
        let continuation = Effect.Continuation.one { (result: Result<String, Never>) async in
            await Task.yield()
            switch result {
            case .success(let value): await values.append(value)
            }
        }

        await continuation.resume(returning: "hello")

        #expect(await values.values == ["hello"])
    }

    @Test(arguments: [Result<Int, Failure>.success(42), .failure(.rejected(7))])
    func `One-shot result delivery preserves either branch`(_ result: Result<Int, Failure>) async {
        let results = Self.Recorder<Result<Int, Self.Failure>>()
        let continuation = Effect.Continuation.one { (received: Result<Int, Self.Failure>) async in
            await results.append(received)
        }

        await continuation.resume(with: result)

        #expect(await results.values == [result])
    }

    @Test
    func `One-shot void delivery invokes only the value callback`() async {
        let calls = Self.Counter()
        let continuation = Effect.Continuation.one(
            onValue: { (_: Void) async in calls.increment() },
            onError: { (_: Self.Failure) async in Issue.record("Unexpected failure callback") }
        )

        await continuation.resume()

        #expect(calls.value == 1)
    }

    @Test
    func `Infallible one-shot void delivery invokes its callback`() async {
        let calls = Self.Counter()
        let continuation = Effect.Continuation.one { (_: Result<Void, Never>) async in
            calls.increment()
        }

        await continuation.resume()

        #expect(calls.value == 1)
    }

    @Test
    func `One-shot delivery transfers a disconnected non-Sendable reference`() async {
        let values = Self.Recorder<Int>()
        let continuation = Effect.Continuation.one(
            onValue: { (value: consuming sending Self.LocalValue) async in
                value.value += 1
                await values.append(value.value)
            },
            onError: { (_: Never) async in }
        )

        await continuation.resume(returning: Self.LocalValue(41))

        #expect(await values.values == [42])
    }

    @Test(arguments: [Result<Int, Failure>.success(42), .failure(.rejected(7))])
    func `Nested observers finish in order before forwarding the same result`(
        _ result: Result<Int, Failure>
    ) async {
        let order = Self.Recorder<String>()
        let results = Self.Recorder<Result<Int, Self.Failure>>()
        let original = Effect.Continuation.one { (received: Result<Int, Self.Failure>) async in
            await order.append("delivery")
            await results.append(received)
        }
        let inner = original.onResume { received in
            await order.append("inner start")
            await Task.yield()
            await results.append(received)
            await order.append("inner finish")
        }
        let outer = inner.onResume { received in
            await order.append("outer start")
            await Task.yield()
            await results.append(received)
            await order.append("outer finish")
        }

        await outer.resume(with: result)

        #expect(await order.values == ["outer start", "outer finish", "inner start", "inner finish", "delivery"])
        #expect(await results.values == [result, result, result])
    }

    @Test
    func `Dropping a one-shot continuation releases its capture without invoking it`() {
        let calls = Self.Counter()
        let releases = Self.Counter()

        Self.discard(Self.retainingCapture(calls: calls, releases: releases))

        #expect(calls.value == 0)
        #expect(releases.value == 1)
    }

    @Test
    func `Resuming a one-shot continuation releases its capture after invocation`() async {
        let calls = Self.Counter()
        let releases = Self.Counter()
        let continuation = Self.retainingCapture(calls: calls, releases: releases)

        await continuation.resume(returning: 42)

        #expect(calls.value == 1)
        #expect(releases.value == 1)
    }

    @Test
    func `Dropping a decorated continuation invokes neither observer nor delivery`() {
        let calls = Self.Counter()
        let releases = Self.Counter()
        let original = Self.retainingCapture(calls: calls, releases: releases)
        let decorated = original.onResume { _ in calls.increment() }

        Self.discard(decorated)

        #expect(calls.value == 0)
        #expect(releases.value == 1)
    }
}
