//
//  AdaptedValueStorageTests.swift
//  Adaption
//
//  Created by treastrain on 2024/10/29.
//

import Foundation
import Testing

@testable import Adaption

@globalActor
private actor StorageTestActor {
    static let shared = StorageTestActor()
}

@StorageTestActor
private func checkPublicAccessFromGlobalActor() {
    @Adaptor(\.testItem) var item
    AdaptedValues[\.testItem] = item
    AdaptedValues[AdaptedValues.TestItemKey.self] = item
}

@Suite(.tags(.storage))
struct AdaptedValueStorageTests {
    @StorageTestActor
    @Test
    func accessFromCustomGlobalActor() {
        var storage = AdaptedValueStorage()
        let item = TestItem(value: 987)
        storage[AdaptedValues.TestItemKey.self] = item
        let stored: TestItem? = storage[AdaptedValues.TestItemKey.self]
        #expect(stored === item)
    }

    @Test
    func storesOptionalNil() throws {
        var storage = AdaptedValueStorage()
        storage[AdaptedValues.TestItemKey.self] = Optional<TestItem?>.some(nil)

        let stored: TestItem?? = storage[AdaptedValues.TestItemKey.self]
        let value = try #require(stored)
        #expect(value == nil)

    }

    @Test
    func getStorageValue() {
        let storage = AdaptedValueStorage()
        let item: (any TestItemProtocol)? = storage[AdaptedValues.TestItemKey.self]
        #expect(item == nil)
    }

    @Test
    func setStorageValue() throws {
        weak var releasedItem: TestItem?
        do {
            var storage = AdaptedValueStorage()
            storage[AdaptedValues.TestItemKey.self] = TestItem(value: 123)

            let storedItem: (any TestItemProtocol)? = storage[AdaptedValues.TestItemKey.self]
            let item = try #require(storedItem as? TestItem)
            releasedItem = item
            #expect(item.value == 123)
            storage[AdaptedValues.TestItemKey.self] = TestItem(value: 987)
            let updatedItem: (any TestItemProtocol)? = storage[AdaptedValues.TestItemKey.self]
            #expect(updatedItem?.value == 987)
        }
        #expect(releasedItem == nil)
    }

    @Test
    func removeStorageValue() {
        var storage = AdaptedValueStorage()
        storage[AdaptedValues.TestItemKey.self] = TestItem(value: 123)
        weak let releasedItem: TestItem? = storage[AdaptedValues.TestItemKey.self]
        #expect(releasedItem != nil)

        storage[AdaptedValues.TestItemKey.self] = Optional<TestItem>.none

        let item: TestItem? = storage[AdaptedValues.TestItemKey.self]
        #expect(item == nil)
        #expect(releasedItem == nil)
    }
}
