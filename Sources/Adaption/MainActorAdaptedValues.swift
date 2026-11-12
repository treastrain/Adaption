//
//  MainActorAdaptedValues.swift
//  Adaption
//
//  Created by treastrain on 2026/11/12.
//

import Foundation

@MainActor
public struct MainActorAdaptedValues {
    private static var current = MainActorAdaptedValues()

    public static subscript<K>(key: K.Type) -> K.Value where K: MainActorAdaptionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }

    public static subscript<T>(_ keyPath: WritableKeyPath<MainActorAdaptedValues, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}

@MainActor
struct MainActorAdaptedValueStorage: ~Copyable {
    private var storage = AdaptedValueTable()

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
            resolveAdaptedValue(
                cached: mainActorStorage[Self.self],
                makeDefault: { defaultValue },
                store: { mainActorStorage[Self.self] = $0 }
            )
        }
        set { mainActorStorage[Self.self] = newValue }
    }
}
