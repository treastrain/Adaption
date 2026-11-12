//
//  MainActorAdaptionKey.swift
//  Adaption
//
//  Created by treastrain on 2026/11/12.
//

import Foundation

@MainActor
public protocol MainActorAdaptionKey {
    associatedtype Value
    static var defaultValue: Self.Value { get }
}
