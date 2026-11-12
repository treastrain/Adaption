//
//  MainActorAdaptor.swift
//  Adaption
//
//  Created by treastrain on 2026/11/12.
//

import Foundation

@MainActor
@propertyWrapper
public struct MainActorAdaptor<T> {
    public init(_ keyPath: WritableKeyPath<MainActorAdaptedValues, T>) {
        self.keyPath = keyPath
    }

    public var wrappedValue: T {
        MainActorAdaptedValues[keyPath]
    }

    private let keyPath: WritableKeyPath<MainActorAdaptedValues, T>
}
