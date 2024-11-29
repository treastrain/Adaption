//
//  AdaptionKey.swift
//  Adaption
//
//  Created by treastrain on 2024/10/23.
//

import Foundation

public protocol AdaptionKey: Sendable {
    associatedtype Value: Sendable
    static var defaultValue: Self.Value { get }
}
