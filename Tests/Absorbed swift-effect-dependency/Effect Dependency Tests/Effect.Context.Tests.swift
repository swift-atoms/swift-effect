#if Dependency
import Dependency
import Testing

import Effect

@testable import Effect

private struct CounterKey: Effect::Effect.Context.Key {
}

extension CounterKey {
    typealias Value = Int
    static var liveValue: Int { 0 }
    static var testValue: Int { 999 }
}

private struct StringKey: Effect::Effect.Context.Key {
}

extension StringKey {
    typealias Value = String
    static var liveValue: String { "live" }
    static var testValue: String { "test" }
}

private struct NoTestValueKey: Effect::Effect.Context.Key {

}

extension NoTestValueKey {
    typealias Value = String
    static var liveValue: String { "default-live" }
}

extension Effect::Effect.Context {
    @Suite("Effect.Context")
    struct Test {

        @Test
        func `default handler returns liveValue`() {
            let value = Effect::Effect.Context.current[CounterKey.self]
            #expect(value == 0)
        }

        @Test
        func `with scope sets handler value`() {
            let result = Effect::Effect.Context.with { handlers in
                handlers[CounterKey.self] = 42
            } operation: {
                Effect::Effect.Context.current[CounterKey.self]
            }

            #expect(result == 42)
        }

        @Test
        func `nested scopes override correctly`() {
            var values: [Int] = []

            Effect::Effect.Context.with { handlers in
                handlers[CounterKey.self] = 1
            } operation: {
                values.append(Effect::Effect.Context.current[CounterKey.self])

                Effect::Effect.Context.with { handlers in
                    handlers[CounterKey.self] = 2
                } operation: {
                    values.append(Effect::Effect.Context.current[CounterKey.self])
                }

                values.append(Effect::Effect.Context.current[CounterKey.self])
            }

            #expect(values == [1, 2, 1])
        }

        @Test
        func `multiple keys in same scope`() {
            let result = Effect::Effect.Context.with { handlers in
                handlers[CounterKey.self] = 100
                handlers[StringKey.self] = "custom"
            } operation: {
                (
                    counter: Effect::Effect.Context.current[CounterKey.self],
                    string: Effect::Effect.Context.current[StringKey.self]
                )
            }

            #expect(result.counter == 100)
            #expect(result.string == "custom")
        }

        @Test
        func `async with scope works`() async {
            let result = await Effect::Effect.Context.with { handlers in
                handlers[CounterKey.self] = 50
            } operation: {
                await Task.yield()
                return Effect::Effect.Context.current[CounterKey.self]
            }

            #expect(result == 50)
        }

        @Test
        func `throwing operation propagates error`() {
            struct Failure: Swift.Error {}

            do {
                try Effect::Effect.Context.with { _ in
                } operation: {
                    throw Failure()
                }
                Issue.record("Expected error to be thrown")
            } catch {
                #expect(error is Failure)
            }
        }

        @Test
        func `handlers storage subscript get/set`() {
            var handlers = Effect::Effect.Context.Handlers()

            #expect(handlers[CounterKey.self] == 0)

            handlers[CounterKey.self] = 123
            #expect(handlers[CounterKey.self] == 123)

            handlers[CounterKey.self] = 456
            #expect(handlers[CounterKey.self] == 456)
        }
    }
}

extension Effect::Effect.Context.Handlers {
    @Suite("Effect.Context.Handlers")
    struct Test {

        @Test
        func `isTestContext returns testValue when true`() {
            var handlers = Effect::Effect.Context.Handlers()
            handlers.isTestContext = true

            #expect(handlers[CounterKey.self] == 999)
            #expect(handlers[StringKey.self] == "test")
        }

        @Test
        func `isTestContext false returns liveValue`() {
            var handlers = Effect::Effect.Context.Handlers()
            handlers.isTestContext = false

            #expect(handlers[CounterKey.self] == 0)
            #expect(handlers[StringKey.self] == "live")
        }

        @Test
        func `forTesting factory sets isTestContext`() {
            let handlers = Effect::Effect.Context.Handlers.forTesting()

            #expect(handlers[CounterKey.self] == 999)
            #expect(handlers.isTestContext)
        }

        @Test
        func `explicit value overrides test/live defaults`() {
            var handlers = Effect::Effect.Context.Handlers.forTesting()
            handlers[CounterKey.self] = 42

            #expect(handlers[CounterKey.self] == 42)
        }

        @Test
        func `testValue defaults to liveValue when not overridden`() {
            let handlers = Effect::Effect.Context.Handlers.forTesting()

            #expect(handlers[NoTestValueKey.self] == "default-live")
        }
    }
}

#endif
