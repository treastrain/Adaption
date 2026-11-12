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
    @MainActor
    private struct Client {
        @Adaptor(\.mainService) var service
    }

    @Test
    func infersMainActorProviderFromShorthand() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        let client = Client()
        #expect(client.service.value == defaultTestItemID)
        let replacement = MainActorTestItem(value: 987)
        MainActorAdaptedValues[\.mainService] = replacement
        #expect(client.service === replacement)
        replacement.value = 456
        #expect(client.service.value == 456)
    }

    @Test
    func labelsSelectIndependentContainers() {
        Adaption.storage = AdaptedValueStorage()
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer {
            Adaption.storage = AdaptedValueStorage()
            Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        }

        @Adaptor(shared: \.testItem) var shared
        @Adaptor(mainActor: \.testItem) var main
        let replacement = MainActorTestItem(value: 987)
        MainActorAdaptedValues[\.testItem] = replacement
        #expect(main === replacement)
        #expect(shared.value == defaultTestItemID)
        AdaptedValues[\.testItem] = TestItem(value: 456)
        #expect(shared.value == 456)
        #expect(main === replacement)
    }

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

extension MainActorAdaptedValues {
    @Item fileprivate var mainService: any MainActorTestItemProtocol = MainActorTestItem(value: defaultTestItemID)
}
