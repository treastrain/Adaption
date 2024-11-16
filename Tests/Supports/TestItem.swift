//
//  TestItem.swift
//  AdaptionTests
//
//  Created by treastrain on 2024/10/23.
//

import Foundation

final class TestItem: TestItemProtocol {
    let value: Int
    let deinitBlock: @Sendable () -> Void
    
    init(value: Int, deinitBlock: @escaping @Sendable () -> Void) {
        self.value = value
        self.deinitBlock = deinitBlock
    }
    
    deinit {
        deinitBlock()
    }
}
