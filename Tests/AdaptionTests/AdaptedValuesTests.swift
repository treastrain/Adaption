//
//  AdaptedValuesTests.swift
//  Adaption
//
//  Created by treastrain on 2024/10/29.
//

import Foundation
import Testing

@testable import Adaption

@MainActor
@Suite(.tags(.values))
struct AdaptedValuesTests {
    private struct NestedDefaultKey: AdaptionKey {
        static var defaultValue: Int { AdaptedValues[LeafDefaultKey.self] + 1 }
    }

    private struct LeafDefaultKey: AdaptionKey {
        static var defaultValue: Int { 41 }
    }

    @Test
    func defaultValueCanResolveAnotherKey() {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        #expect(AdaptedValues[NestedDefaultKey.self] == 42)
        AdaptedValues[LeafDefaultKey.self] = 99
        #expect(AdaptedValues[NestedDefaultKey.self] == 42)
    }

    @Test
    func getValuesValue() {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        let item = AdaptedValues[\.testItem]
        #expect(item.value == defaultTestItemID)
        #expect(item === AdaptedValues[\.testItem])
        #expect(item === AdaptedValues[AdaptedValues.TestItemKey.self])
    }

    @Test
    func setValuesValue() {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        weak var releasedItem: TestItem?
        do {
            let item = TestItem(value: 987)
            releasedItem = item
            AdaptedValues[\.testItem] = item
            #expect(AdaptedValues[\.testItem] === item)
            #expect(AdaptedValues[AdaptedValues.TestItemKey.self] === item)
        }

        #expect(releasedItem != nil)
        Adaption.storage = AdaptedValueStorage()
        #expect(releasedItem == nil)
        #expect(AdaptedValues[\.testItem].value == defaultTestItemID)
    }

    @Test
    func setKeyValueReleasesPreviousValue() {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        weak let previousItem = AdaptedValues[\.testItem]
        #expect(previousItem != nil)
        let replacement = TestItem(value: 987)
        AdaptedValues[AdaptedValues.TestItemKey.self] = replacement

        #expect(previousItem == nil)
        #expect(AdaptedValues[\.testItem] === replacement)
        #expect(AdaptedValues[\.testItem].value == 987)
    }

    @Test
    func macroItemValue() {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        let defaultItem = AdaptedValues[\.macroTestItem]
        #expect(defaultItem.value == defaultTestItemID)
        #expect(defaultItem === AdaptedValues[\.macroTestItem])

        let replacement = TestItem(value: 987)
        AdaptedValues[\.macroTestItem] = replacement
        #expect(AdaptedValues[\.macroTestItem] === replacement)
        #expect(AdaptedValues[\.testItem].value == defaultTestItemID)
    }
}
