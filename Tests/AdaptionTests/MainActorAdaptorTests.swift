//
//  MainActorAdaptorTests.swift
//  Adaption
//
//  Created by treastrain on 2026/11/13.
//

import Foundation
import Testing

@testable import Adaption

@MainActor
@Suite(.tags(.adaptor))
struct MainActorAdaptorTests {
    @Test
    func getAdaptorValue() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        @MainActorAdaptor(\.testItem) var item
        #expect(item.value == defaultTestItemID)
        #expect(item === MainActorAdaptedValues[\.testItem])
    }

    @Test
    func getUpdatedAdaptorValue() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        @MainActorAdaptor(\.testItem) var item
        #expect(item.value == defaultTestItemID)

        let replacement = MainActorTestItem(value: 987)
        MainActorAdaptedValues[\.testItem] = replacement
        #expect(item === replacement)
        #expect(item.value == 987)
    }

    @Test
    func getMacroAdaptorValue() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        @MainActorAdaptor(\.macroTestItem) var item
        #expect(item.value == defaultTestItemID)

        let replacement = MainActorTestItem(value: 987)
        MainActorAdaptedValues[\.macroTestItem] = replacement
        #expect(item === replacement)
    }
}
