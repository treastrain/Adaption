//
//  AdaptedValuesTests.swift
//  Adaption
//
//  Created by treastrain on 2024/10/29.
//

import Foundation
import Testing

@testable import Adaption

@Suite(.tags(.values), .serialized)
struct AdaptedValuesTests {
    @Test
    func getValuesValue() throws {
        let testItemID = defaultTestItemID
        let otherTestItemID = 987
        
        let value = AdaptedValues[\.testItem]
        let item = try #require(value as? TestItem)
        #expect(item == TestItem(value: testItemID, deinitBlock: {}))
        #expect(item != TestItem(value: otherTestItemID, deinitBlock: {}))
    }
    
    @Test
    func setValuesValue() async throws {
        let testItemID = defaultTestItemID
        let otherTestItemID = 987
        
        try await confirmation { deinitedItem in
            AdaptedValues[\.testItem] = TestItem(value: testItemID, deinitBlock: { deinitedItem() })
            
            let item = try #require(AdaptedValues[\.testItem] as? TestItem)
            #expect(item == TestItem(value: testItemID, deinitBlock: {}))
            #expect(item != TestItem(value: otherTestItemID, deinitBlock: {}))
            
            Adaption.storage = AdaptedValueStorage()
        }
    }
}
