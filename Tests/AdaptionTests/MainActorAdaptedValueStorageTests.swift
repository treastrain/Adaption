//
//  MainActorAdaptedValueStorageTests.swift
//  Adaption
//
//  Created by treastrain on 2026/11/13.
//

import Foundation
import Testing

@testable import Adaption

@MainActor
@Suite(.tags(.storage))
struct MainActorAdaptedValueStorageTests {
    @Test
    func getStorageValue() {
        let storage = MainActorAdaptedValueStorage()
        let item: (any MainActorTestItemProtocol)? = storage[MainActorAdaptedValues.TestItemKey.self]
        #expect(item == nil)
    }

    @Test
    func setStorageValue() throws {
        weak var releasedItem: MainActorTestItem?
        do {
            var storage = MainActorAdaptedValueStorage()
            storage[MainActorAdaptedValues.TestItemKey.self] = MainActorTestItem(value: 123)

            let storedItem: (any MainActorTestItemProtocol)? = storage[MainActorAdaptedValues.TestItemKey.self]
            let item = try #require(storedItem as? MainActorTestItem)
            releasedItem = item
            #expect(item.value == 123)
            item.value = 987
            let updatedItem: (any MainActorTestItemProtocol)? = storage[MainActorAdaptedValues.TestItemKey.self]
            #expect(updatedItem?.value == 987)
        }
        #expect(releasedItem == nil)
    }

    @Test
    func removeStorageValue() {
        var storage = MainActorAdaptedValueStorage()
        storage[MainActorAdaptedValues.TestItemKey.self] = MainActorTestItem(value: 123)
        weak let releasedItem: MainActorTestItem? = storage[MainActorAdaptedValues.TestItemKey.self]
        #expect(releasedItem != nil)

        storage[MainActorAdaptedValues.TestItemKey.self] = Optional<MainActorTestItem>.none

        let item: MainActorTestItem? = storage[MainActorAdaptedValues.TestItemKey.self]
        #expect(item == nil)
        #expect(releasedItem == nil)
    }
}
