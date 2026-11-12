//
//  MainActorAdaptedValues.swift
//  Adaption
//
//  Created by treastrain on 2026/11/12.
//

import Foundation

@MainActor
public struct MainActorAdaptedValues: Sendable {
    private static var shared = MainActorAdaptedValues()

    @TaskLocal
    public static var current: MainActorAdaptedValues?

    @TaskLocal
    fileprivate static var currentRecorder: OverrideRecorder?

    var table: AdaptedValueTable<Any>

    public init() {
        table = AdaptedValueTable<Any>()
    }

    public static subscript<K>(key: K.Type) -> K.Value where K: MainActorAdaptionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }

    public static subscript<T>(_ keyPath: WritableKeyPath<MainActorAdaptedValues, T>) -> T {
        get { shared[keyPath: keyPath] }
        set { shared[keyPath: keyPath] = newValue }
    }

    public subscript<K>(key: K.Type) -> K.Value where K: MainActorAdaptionKey {
        get { table[key] ?? Self[key] }
        set { table[key] = newValue }
    }

    public subscript<T>(override keyPath: WritableKeyPath<MainActorAdaptedValues, T>) -> T {
        get { self[keyPath: keyPath] }
        set { set(keyPath, newValue) }
    }

    public mutating func set<Value>(
        _ keyPath: WritableKeyPath<MainActorAdaptedValues, Value>,
        _ value: Value
    ) {
        let recorder = OverrideRecorder(table: table)
        MainActorAdaptedValues.$currentRecorder.withValue(recorder) {
            var receiver = MainActorAdaptedValues()
            receiver[keyPath: keyPath] = value
        }
        table = recorder.table
    }
}

extension MainActorAdaptedValues {
    @discardableResult
    public static func withValue<Value, ReturnValue, Failure: Error>(
        _ keyPath: WritableKeyPath<MainActorAdaptedValues, Value>,
        _ valueDuringOperation: sending Value,
        operation: () throws(Failure) -> ReturnValue,
        file: String = #fileID,
        line: UInt = #line
    ) throws(Failure) -> ReturnValue {
        var values = current ?? MainActorAdaptedValues()
        values.set(keyPath, valueDuringOperation)
        let result: Result<ReturnValue, Failure> = $current.withValue(
            values,
            operation: {
                do throws(Failure) {
                    return .success(try operation())
                } catch {
                    return .failure(error)
                }
            },
            file: file,
            line: line
        )
        return try result.get()
    }

    @discardableResult
    public static func withValue<Value, ReturnValue, Failure: Error>(
        _ keyPath: WritableKeyPath<MainActorAdaptedValues, Value>,
        _ valueDuringOperation: sending Value,
        operation: nonisolated(nonsending) () async throws(Failure) -> ReturnValue,
        file: String = #fileID,
        line: UInt = #line
    ) async throws(Failure) -> ReturnValue {
        var values = current ?? MainActorAdaptedValues()
        values.set(keyPath, valueDuringOperation)
        let result: Result<ReturnValue, Failure> = await $current.withValue(
            values,
            operation: {
                do throws(Failure) {
                    return .success(try await operation())
                } catch {
                    return .failure(error)
                }
            },
            file: file,
            line: line
        )
        return try result.get()
    }

    @discardableResult
    public static func withValue<K: MainActorAdaptionKey, ReturnValue, Failure: Error>(
        _ key: K.Type,
        _ valueDuringOperation: sending K.Value,
        operation: () throws(Failure) -> ReturnValue,
        file: String = #fileID,
        line: UInt = #line
    ) throws(Failure) -> ReturnValue {
        var values = current ?? MainActorAdaptedValues()
        values[key] = valueDuringOperation
        let result: Result<ReturnValue, Failure> = $current.withValue(
            values,
            operation: {
                do throws(Failure) {
                    return .success(try operation())
                } catch {
                    return .failure(error)
                }
            },
            file: file,
            line: line
        )
        return try result.get()
    }

    @discardableResult
    public static func withValue<K: MainActorAdaptionKey, ReturnValue, Failure: Error>(
        _ key: K.Type,
        _ valueDuringOperation: sending K.Value,
        operation: nonisolated(nonsending) () async throws(Failure) -> ReturnValue,
        file: String = #fileID,
        line: UInt = #line
    ) async throws(Failure) -> ReturnValue {
        var values = current ?? MainActorAdaptedValues()
        values[key] = valueDuringOperation
        let result: Result<ReturnValue, Failure> = await $current.withValue(
            values,
            operation: {
                do throws(Failure) {
                    return .success(try await operation())
                } catch {
                    return .failure(error)
                }
            },
            file: file,
            line: line
        )
        return try result.get()
    }

    @discardableResult
    public static func withValues<ReturnValue, Failure: Error>(
        _ mutation: (inout MainActorAdaptedValues) -> Void,
        operation: () throws(Failure) -> ReturnValue,
        file: String = #fileID,
        line: UInt = #line
    ) throws(Failure) -> ReturnValue {
        var values = current ?? MainActorAdaptedValues()
        mutation(&values)
        let result: Result<ReturnValue, Failure> = $current.withValue(
            values,
            operation: {
                do throws(Failure) {
                    return .success(try operation())
                } catch {
                    return .failure(error)
                }
            },
            file: file,
            line: line
        )
        return try result.get()
    }

    @discardableResult
    public static func withValues<ReturnValue, Failure: Error>(
        _ mutation: (inout MainActorAdaptedValues) -> Void,
        operation: nonisolated(nonsending) () async throws(Failure) -> ReturnValue,
        file: String = #fileID,
        line: UInt = #line
    ) async throws(Failure) -> ReturnValue {
        var values = current ?? MainActorAdaptedValues()
        mutation(&values)
        let result: Result<ReturnValue, Failure> = await $current.withValue(
            values,
            operation: {
                do throws(Failure) {
                    return .success(try await operation())
                } catch {
                    return .failure(error)
                }
            },
            file: file,
            line: line
        )
        return try result.get()
    }
}

@MainActor
private final class OverrideRecorder: Sendable {
    var table: AdaptedValueTable<Any>

    init(table: AdaptedValueTable<Any>) {
        self.table = table
    }
}

@MainActor
struct MainActorAdaptedValueStorage: ~Copyable {
    private var storage = AdaptedValueTable<Any>()

    subscript<K: MainActorAdaptionKey, V>(_ key: K.Type) -> V? {
        get { storage[key] }
        set { storage[key] = newValue }
    }
}

@MainActor
var mainActorStorage = MainActorAdaptedValueStorage()

extension MainActorAdaptionKey {
    fileprivate static var currentValue: Self.Value {
        get {
            MainActorAdaptedValues.current?.table[Self.self]
                ?? resolveAdaptedValue(
                    cached: mainActorStorage[Self.self],
                    makeDefault: { defaultValue },
                    store: { mainActorStorage[Self.self] = $0 }
                )
        }
        set {
            if let recorder = MainActorAdaptedValues.currentRecorder {
                recorder.table[Self.self] = newValue
            } else {
                mainActorStorage[Self.self] = newValue
            }
        }
    }
}
