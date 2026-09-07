import Effect
import Testing

extension Effect.`Continuations deliver results` {
    @Test
    func `Multi-shot delivery preserves the order of awaited calls`() async {
        let values = Self.Recorder<Int>()
        let continuation = Effect.Continuation.multi { (result: Result<Int, Never>) async in
            await Task.yield()
            switch result {
            case .success(let value): await values.append(value)
            }
        }

        await continuation.resume(returning: 1)
        await continuation.resume(returning: 2)
        await continuation.resume(returning: 3)

        #expect(await values.values == [1, 2, 3])
    }

    @Test
    func `Multi-shot copies invoke the same callback independently`() async {
        let calls = Self.Counter()
        let original = Effect.Continuation.multi { (_: Result<Void, Never>) async in
            calls.increment()
        }
        let first = original
        let second = original

        await original.resume()
        await first.resume()
        await second.resume()

        #expect(calls.value == 3)
    }

    @Test
    func `Multi-shot delivery preserves interleaved results and typed failures`() async {
        let results = Self.Recorder<Result<Int, Self.Failure>>()
        let continuation = Effect.Continuation.multi { (result: Result<Int, Self.Failure>) async in
            await results.append(result)
        }

        await continuation.resume(with: .success(1))
        await continuation.resume(throwing: .rejected(7))
        await continuation.resume(with: .failure(.rejected(8)))
        await continuation.resume(returning: 2)

        #expect(await results.values == [.success(1), .failure(.rejected(7)), .failure(.rejected(8)), .success(2)])
    }

    @Test
    func `Fallible multi-shot void delivery remains reusable after failure`() async {
        let results = Self.Recorder<Bool>()
        let continuation = Effect.Continuation.multi { (result: Result<Void, Self.Failure>) async in
            switch result {
            case .success: await results.append(true)
            case .failure: await results.append(false)
            }
        }

        await continuation.resume()
        await continuation.resume(throwing: .rejected(7))
        await continuation.resume()

        #expect(await results.values == [true, false, true])
    }

    @Test
    func `Concurrent multi-shot copies deliver every invocation once`() async {
        let values = Self.Recorder<Int>()
        let continuation = Effect.Continuation.multi { (result: Result<Int, Never>) async in
            await Task.yield()
            switch result {
            case .success(let value): await values.append(value)
            }
        }

        await withTaskGroup(of: Void.self) { group in
            for value in 0..<64 {
                group.addTask {
                    await continuation.resume(returning: value)
                }
            }
        }

        #expect(await values.values.sorted() == Array(0..<64))
    }
}
