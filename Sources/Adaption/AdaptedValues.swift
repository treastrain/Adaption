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

    public static subscript<K>(key: K.Type) -> K.Value where K: AdaptionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }

    public static subscript<T: Sendable>(_ keyPath: WritableKeyPath<AdaptedValues, T>) -> T {
        get { lock.withLock { $0[keyPath: keyPath] } }
        set { lock.withLock { $0[keyPath: keyPath] = newValue } }
    }
}

struct AdaptedValueStorage: Sendable, ~Copyable {
    private let lock = Mutex(AdaptedValueTable())

    subscript<K: AdaptionKey, V: Sendable>(_ key: K.Type) -> V? {
        get { lock.withLock { $0[key] } }
        set { lock.withLock { $0[key] = newValue } }
    }
}

nonisolated(unsafe) var storage = AdaptedValueStorage()

extension AdaptionKey {
    fileprivate static var currentValue: Self.Value {
        get {
            resolveAdaptedValue(
                cached: storage[Self.self],
                makeDefault: { defaultValue },
                store: { storage[Self.self] = $0 }
            )
        }
        set { storage[Self.self] = newValue }
    }
}
