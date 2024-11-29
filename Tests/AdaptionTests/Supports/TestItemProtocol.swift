//
//  TestItemProtocol.swift
//  AdaptionTests
//
//  Created by treastrain on 2024/10/23.
//

import Foundation

protocol TestItemProtocol: Equatable, Sendable {
    var value: Int { get }
    var deinitBlock: @Sendable () -> Void { get }
}

extension TestItemProtocol {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}
