//
//  MainActorAdaptedValuesTests.swift
//  Adaption
//
//  Created by treastrain on 2026/11/13.
//

import Foundation
import Testing

@testable import Adaption

@MainActor
@Suite(.tags(.values))
struct MainActorAdaptedValuesTests {
    private struct CountingDefaultKey: MainActorAdaptionKey {
        static var initializationCount = 0

        static var defaultValue: MainActorTestItem {
            initializationCount += 1
            let dependency = MainActorAdaptedValues[MainActorAdaptedValues.TestItemKey.self]
            return MainActorTestItem(value: dependency.value)
        }
    }

    @Test
    func defaultValueRunsOnMainActorOnlyWhenMissing() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        CountingDefaultKey.initializationCount = 0
        defer {
            Adaption.mainActorStorage = MainActorAdaptedValueStorage()
            CountingDefaultKey.initializationCount = 0
        }

        let first = MainActorAdaptedValues[CountingDefaultKey.self]
        #expect(first.value == defaultTestItemID)
        #expect(MainActorAdaptedValues[CountingDefaultKey.self] === first)
        #expect(CountingDefaultKey.initializationCount == 1)

        let replacement = MainActorTestItem(value: 987)
        MainActorAdaptedValues[CountingDefaultKey.self] = replacement
        #expect(MainActorAdaptedValues[CountingDefaultKey.self] === replacement)
        #expect(CountingDefaultKey.initializationCount == 1)
    }

    @Test
    func getValuesValue() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        let item = MainActorAdaptedValues[\.testItem]
        #expect(item.value == defaultTestItemID)
        #expect(item === MainActorAdaptedValues[\.testItem])
        #expect(item === MainActorAdaptedValues[MainActorAdaptedValues.TestItemKey.self])
    }

    @Test
    func setValuesValue() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        weak var releasedItem: MainActorTestItem?
        do {
            let item = MainActorTestItem(value: 987)
            releasedItem = item
            MainActorAdaptedValues[\.testItem] = item
            #expect(MainActorAdaptedValues[\.testItem] === item)
            #expect(MainActorAdaptedValues[MainActorAdaptedValues.TestItemKey.self] === item)
        }

        #expect(releasedItem != nil)
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        #expect(releasedItem == nil)
        #expect(MainActorAdaptedValues[\.testItem].value == defaultTestItemID)
    }

    @Test
    func setKeyValueReleasesPreviousValue() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        weak let previousItem = MainActorAdaptedValues[\.testItem]
        #expect(previousItem != nil)
        let replacement = MainActorTestItem(value: 987)
        MainActorAdaptedValues[MainActorAdaptedValues.TestItemKey.self] = replacement

        #expect(previousItem == nil)
        #expect(MainActorAdaptedValues[\.testItem] === replacement)
        #expect(MainActorAdaptedValues[\.testItem].value == 987)
    }

    @Test
    func macroItemValue() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        let defaultItem = MainActorAdaptedValues[\.macroTestItem]
        #expect(defaultItem.value == defaultTestItemID)
        #expect(defaultItem === MainActorAdaptedValues[\.macroTestItem])

        let replacement = MainActorTestItem(value: 987)
        MainActorAdaptedValues[\.macroTestItem] = replacement
        #expect(MainActorAdaptedValues[\.macroTestItem] === replacement)
        #expect(MainActorAdaptedValues[\.testItem].value == defaultTestItemID)
    }
}
