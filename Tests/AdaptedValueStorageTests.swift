//
//  AdaptedValueStorageTests.swift
//  Adaption
//
//  Created by treastrain on 2024/10/29.
//

import Foundation
import Testing

@testable import Adaption

@Suite(.tags(.storage))
struct AdaptedValueStorageTests {
    @Test
    func getStorageValue() {
        let storage = AdaptedValueStorage()
        let nilItem: (any TestItemProtocol)? = storage[AdaptedValues.TestItemKey.self]
        #expect(nilItem == nil)
    }
    
    @Test
    func setStorageValue() async throws {
        var storage: _! = AdaptedValueStorage()
        
        try await confirmation { deinitedItem in
            let testItemID = 123
            storage[AdaptedValues.TestItemKey.self] = TestItem(value: testItemID, deinitBlock: { deinitedItem() })
            
            let newItemOrNil: (any TestItemProtocol)? = storage[AdaptedValues.TestItemKey.self]
            let newItem = try #require(newItemOrNil)
            #expect(newItem.value == testItemID)
            
            storage = nil
        }
    }
}
