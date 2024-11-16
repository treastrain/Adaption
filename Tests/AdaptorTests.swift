//
//  AdaptorTests.swift
//  Adaption
//
//  Created by treastrain on 2024/11/17.
//

import Foundation
import Testing

@testable import Adaption

@Suite(.tags(.adaptor))
struct AdaptorTests {
    @Test
    func getAdaptorValue() throws {
        let testItemID = defaultTestItemID
        let otherTestItemID = 987
        
        @Adaptor(\.testItem) var item
        let unwrappedItem = try #require(item as? TestItem)
        #expect(unwrappedItem == TestItem(value: testItemID, deinitBlock: {}))
        #expect(unwrappedItem != TestItem(value: otherTestItemID, deinitBlock: {}))
    }
}
