//
//  AdaptedValueTable.swift
//  Adaption
//
//  Created by treastrain on 2026/11/13.
//

import Foundation

struct AdaptedValueTable<Element> {
    private var values: [String: Element] = [:]
}

extension AdaptedValueTable where Element == Any {
    subscript<Value>(_ key: Any.Type) -> Value? {
        get { values[String(describing: key)] as? Value }
        set { values[String(describing: key)] = newValue }
    }
}

extension AdaptedValueTable: Sendable where Element == any Sendable {
    subscript<Value: Sendable>(_ key: Any.Type) -> Value? {
        get { values[String(describing: key)] as? Value }
        set { values[String(describing: key)] = newValue }
    }
}

func resolveAdaptedValue<Value>(
    cached: Value?,
    makeDefault: () -> Value,
    store: (Value) -> Void
) -> Value {
    if let cached {
        return cached
    }
    let value = makeDefault()
    store(value)
    return value
}
