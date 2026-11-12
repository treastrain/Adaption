//
//  AdaptorTests.swift
//  Adaption
//
//  Created by treastrain on 2024/11/17.
//

import Foundation
import Testing

@testable import Adaption

@MainActor
@Suite(.tags(.adaptor))
struct AdaptorTests {
    @Test
    func getAdaptorValue() {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        @Adaptor(\.testItem) var item
        #expect(item.value == defaultTestItemID)
        #expect(item === AdaptedValues[\.testItem])
    }

    @Test
    func getUpdatedAdaptorValue() {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        @Adaptor(\.testItem) var item
        #expect(item.value == defaultTestItemID)

        let replacement = TestItem(value: 987)
        AdaptedValues[\.testItem] = replacement
        #expect(item === replacement)
        #expect(item.value == 987)
    }

    @Test
    func getMacroAdaptorValue() {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        @Adaptor(\.macroTestItem) var item
        #expect(item.value == defaultTestItemID)

        let replacement = TestItem(value: 987)
        AdaptedValues[\.macroTestItem] = replacement
        #expect(item === replacement)
    }
}
