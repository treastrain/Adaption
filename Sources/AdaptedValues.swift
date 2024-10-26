//
//  AdaptedValues.swift
//  Adaption
//
//  Created by treastrain on 2024/10/23.
//

import Foundation
import Synchronization

// The locking logic is inspired by https://github.com/swiftlang/swift-foundation/blob/swift-6.0-RELEASE/Sources/FoundationEssentials/Formatting/FormatterCache.swift

public struct AdaptedValues: Sendable {
    private static let lock = Mutex(AdaptedValues())
    
    public static subscript<K>(key: K.Type) -> K.Value where K : AdaptionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }
    
    public static subscript<T: Sendable>(_ keyPath: WritableKeyPath<AdaptedValues, T>) -> T {
        get { lock.withLock { $0[keyPath: keyPath] } }
        set { lock.withLock { $0[keyPath: keyPath] = newValue } }
    }
}

private struct AdaptedValueStorage: Sendable, ~Copyable {
    private let lock = Mutex<[String : Any]>([:])
    
    fileprivate subscript<K: AdaptionKey, V: Sendable>(_ key: K.Type) -> V? {
        get { lock.withLock { $0[key.storageKey] as? V } }
        set { lock.withLock { $0[key.storageKey] = newValue } }
    }
}

private nonisolated(unsafe) var storage = AdaptedValueStorage()

extension AdaptionKey {
    fileprivate static var storageKey: String { "\(Self.self)" }
    
    fileprivate static var currentValue: Self.Value {
        get {
            if let existed: Self.Value = storage[Self.self] {
                return existed
            } else {
                let instance = defaultValue
                storage[Self.self] = instance
                return instance
            }
        }
        set { storage[Self.self] = newValue }
    }
}
