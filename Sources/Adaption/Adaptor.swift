//
//  Adaptor.swift
//  Adaption
//
//  Created by treastrain on 2024/10/23.
//

import Foundation

@propertyWrapper
public struct Adaptor<Provider: AdaptorProvider> {
    private let provider: Provider

    public var wrappedValue: Provider.Value { provider.value }

    public init<Value>(shared keyPath: WritableKeyPath<AdaptedValues, Value>) where Provider == SharedAdaptorProvider<Value> {
        provider = SharedAdaptorProvider(keyPath)
    }

    public init<Value>(_ keyPath: WritableKeyPath<AdaptedValues, Value>) where Provider == SharedAdaptorProvider<Value> {
        self.init(shared: keyPath)
    }

    @MainActor
    public init<Value>(mainActor keyPath: WritableKeyPath<MainActorAdaptedValues, Value>) where Provider == MainActorAdaptorProvider<Value> {
        provider = MainActorAdaptorProvider(keyPath)
    }

    @MainActor
    public init<Value>(_ keyPath: WritableKeyPath<MainActorAdaptedValues, Value>) where Provider == MainActorAdaptorProvider<Value> {
        self.init(mainActor: keyPath)
    }
}

public protocol AdaptorProvider {
    associatedtype Value
    var value: Value { get }
}

public struct SharedAdaptorProvider<Value: Sendable>: AdaptorProvider {
    private let keyPath: WritableKeyPath<AdaptedValues, Value>

    fileprivate init(_ keyPath: WritableKeyPath<AdaptedValues, Value>) {
        self.keyPath = keyPath
    }

    public var value: Value { AdaptedValues[keyPath] }
}

@MainActor
public struct MainActorAdaptorProvider<Value>: @MainActor AdaptorProvider {
    private let keyPath: WritableKeyPath<MainActorAdaptedValues, Value>

    fileprivate init(_ keyPath: WritableKeyPath<MainActorAdaptedValues, Value>) {
        self.keyPath = keyPath
    }

    public var value: Value { MainActorAdaptedValues[keyPath] }
}
