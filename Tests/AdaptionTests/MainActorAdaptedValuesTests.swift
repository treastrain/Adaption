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
