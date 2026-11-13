//
//  AdaptedValues+.swift
//  AdaptionTests
//
//  Created by treastrain on 2024/10/23.
//

import Adaption
import Foundation

let defaultTestItemID = 123_456_789

extension AdaptedValues {
    var testItem: any TestItemProtocol {
        get { Self[TestItemKey.self] }
        set { Self[TestItemKey.self] = newValue }
    }

    struct TestItemKey: AdaptionKey {
        typealias Value = any TestItemProtocol
        static var defaultValue: Value {
            TestItem(value: defaultTestItemID)
        }
    }

    @Item var macroTestItem: any TestItemProtocol = TestItem(value: defaultTestItemID)
    @Item var inferredTestItem = TestItem(value: defaultTestItemID)
    @Item var inferredClosureItem = { TestItem(value: defaultTestItemID) }()
}
