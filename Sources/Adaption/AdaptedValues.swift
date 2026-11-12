//
//  AdaptedValues.swift
//  Adaption
//
//  Created by treastrain on 2024/10/23.
//

import Foundation
import Synchronization

public struct AdaptedValues: Sendable {
    private static let lock = Mutex(AdaptedValues())

    @TaskLocal
    public static var current: AdaptedValues?

    @TaskLocal
    fileprivate static var currentRecorder: OverrideRecorder?

    var table: AdaptedValueTable<any Sendable>

    public init() {
        table = AdaptedValueTable<any Sendable>()
    }

    public static subscript<K>(key: K.Type) -> K.Value where K: AdaptionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }

    public static subscript<T: Sendable>(_ keyPath: WritableKeyPath<AdaptedValues, T>) -> T {
        get { lock.withLock { $0[keyPath: keyPath] } }
        set { lock.withLock { $0[keyPath: keyPath] = newValue } }
    }

    public subscript<K>(key: K.Type) -> K.Value where K: AdaptionKey {
        get { table[key] ?? Self[key] }
        set { table[key] = newValue }
    }

    public subscript<T: Sendable>(override keyPath: WritableKeyPath<AdaptedValues, T>) -> T {
        get { self[keyPath: keyPath] }
        set { set(keyPath, newValue) }
    }

    public mutating func set<Value: Sendable>(
        _ keyPath: WritableKeyPath<AdaptedValues, Value>,
        _ value: Value
    ) {
        let recorder = OverrideRecorder(table: table)
        AdaptedValues.$currentRecorder.withValue(recorder) {
            var receiver = AdaptedValues()
            receiver[keyPath: keyPath] = value
        }
        table = recorder.table.withLock { $0 }
    }
}

extension AdaptedValues {
    @discardableResult
    public static func withValue<Value: Sendable, ReturnValue, Failure: Error>(
        _ keyPath: WritableKeyPath<AdaptedValues, Value>,
        _ valueDuringOperation: Value,
        operation: () throws(Failure) -> ReturnValue,
        file: String = #fileID,
        line: UInt = #line
    ) throws(Failure) -> ReturnValue {
        var values = current ?? AdaptedValues()
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
    nonisolated(nonsending)
        public static func withValue<Value: Sendable, ReturnValue, Failure: Error>(
            _ keyPath: WritableKeyPath<AdaptedValues, Value>,
            _ valueDuringOperation: Value,
            operation: nonisolated(nonsending) () async throws(Failure) -> ReturnValue,
            file: String = #fileID,
            line: UInt = #line
        ) async throws(Failure) -> ReturnValue
    {
        var values = current ?? AdaptedValues()
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
    public static func withValue<K: AdaptionKey, ReturnValue, Failure: Error>(
        _ key: K.Type,
        _ valueDuringOperation: K.Value,
        operation: () throws(Failure) -> ReturnValue,
        file: String = #fileID,
        line: UInt = #line
    ) throws(Failure) -> ReturnValue {
        var values = current ?? AdaptedValues()
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
    nonisolated(nonsending)
        public static func withValue<K: AdaptionKey, ReturnValue, Failure: Error>(
            _ key: K.Type,
            _ valueDuringOperation: K.Value,
            operation: nonisolated(nonsending) () async throws(Failure) -> ReturnValue,
            file: String = #fileID,
            line: UInt = #line
        ) async throws(Failure) -> ReturnValue
    {
        var values = current ?? AdaptedValues()
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
        _ mutation: (inout AdaptedValues) -> Void,
        operation: () throws(Failure) -> ReturnValue,
        file: String = #fileID,
        line: UInt = #line
    ) throws(Failure) -> ReturnValue {
        var values = current ?? AdaptedValues()
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
    nonisolated(nonsending)
        public static func withValues<ReturnValue, Failure: Error>(
            _ mutation: (inout AdaptedValues) -> Void,
            operation: nonisolated(nonsending) () async throws(Failure) -> ReturnValue,
            file: String = #fileID,
            line: UInt = #line
        ) async throws(Failure) -> ReturnValue
    {
        var values = current ?? AdaptedValues()
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

private final class OverrideRecorder: Sendable {
    let table: Mutex<AdaptedValueTable<any Sendable>>

    init(table: AdaptedValueTable<any Sendable>) {
        self.table = Mutex(table)
    }
}

struct AdaptedValueStorage: Sendable, ~Copyable {
    private let lock = Mutex(AdaptedValueTable<any Sendable>())

    subscript<K: AdaptionKey, V: Sendable>(_ key: K.Type) -> V? {
        get { lock.withLock { $0[key] } }
        set { lock.withLock { $0[key] = newValue } }
    }
}

nonisolated(unsafe) var storage = AdaptedValueStorage()

extension AdaptionKey {
    fileprivate static var currentValue: Self.Value {
        get {
            AdaptedValues.current?.table[Self.self]
                ?? resolveAdaptedValue(
                    cached: storage[Self.self],
                    makeDefault: { defaultValue },
                    store: { storage[Self.self] = $0 }
                )
        }
        set {
            if let recorder = AdaptedValues.currentRecorder {
                recorder.table.withLock { $0[Self.self] = newValue }
            } else {
                storage[Self.self] = newValue
            }
        }
    }
}
