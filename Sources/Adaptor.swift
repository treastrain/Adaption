//
//  Adaptor.swift
//  Adaption
//
//  Created by treastrain on 2024/10/23.
//

import Foundation

@propertyWrapper
public struct Adaptor<T: Sendable> {
    public init(_ keyPath: WritableKeyPath<AdaptedValues, T>) {
        self.keyPath = keyPath
    }
    
    public var wrappedValue: T {
        get { AdaptedValues[keyPath] }
        set { AdaptedValues[keyPath] = newValue }
    }
    
    private let keyPath: WritableKeyPath<AdaptedValues, T>
}
