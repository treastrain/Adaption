//
//  TaskLocalMainActorAdaptedValuesTests.swift
//  Adaption
//
//  Created by treastrain on 2026/11/13.
//

import Foundation
import Testing

@testable import Adaption

@MainActor
@Suite(.tags(.values), .serialized)
struct TaskLocalMainActorAdaptedValuesTests {
    @MainActor
    private struct Client {
        @MainActorAdaptor(mainActor: \.testItem) var item
    }

    private enum TestCustomError: Error, Equatable {
        case somethingWrong
    }

    @Test
    func priorityOverGlobal() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        let globalItem = MainActorTestItem(value: 100)
        MainActorAdaptedValues[\.testItem] = globalItem
        #expect(MainActorAdaptedValues[\.testItem].value == 100)

        let localItem = MainActorTestItem(value: 200)
        MainActorAdaptedValues.withValue(\.testItem, localItem) {
            #expect(MainActorAdaptedValues[\.testItem].value == 200)
            #expect((MainActorAdaptedValues[\.testItem] as? MainActorTestItem) === localItem)

            let client = Client()
            #expect(client.item.value == 200)
            #expect((client.item as? MainActorTestItem) === localItem)
        }

        #expect(MainActorAdaptedValues[\.testItem].value == 100)
        #expect((MainActorAdaptedValues[\.testItem] as? MainActorTestItem) === globalItem)
    }

    @Test
    func directTaskLocalCurrentWithValue() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        let globalItem = MainActorTestItem(value: 100)
        MainActorAdaptedValues[\.testItem] = globalItem

        var values = MainActorAdaptedValues()
        let localItem = MainActorTestItem(value: 300)
        values[override: \.testItem] = localItem

        MainActorAdaptedValues.$current.withValue(values) {
            #expect(MainActorAdaptedValues[\.testItem].value == 300)
            #expect((MainActorAdaptedValues[\.testItem] as? MainActorTestItem) === localItem)
        }

        #expect(MainActorAdaptedValues[\.testItem].value == 100)
    }

    @Test
    func withValueByKeyType() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        let localItem = MainActorTestItem(value: 400)
        MainActorAdaptedValues.withValue(MainActorAdaptedValues.TestItemKey.self, localItem) {
            #expect(MainActorAdaptedValues[MainActorAdaptedValues.TestItemKey.self].value == 400)
            #expect(MainActorAdaptedValues[\.testItem].value == 400)
        }

        #expect(MainActorAdaptedValues[\.testItem].value == defaultTestItemID)
    }

    @Test
    func nestedWithValue() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        let item1 = MainActorTestItem(value: 111)
        let item2 = MainActorTestItem(value: 222)
        let macroItem = MainActorTestItem(value: 333)

        MainActorAdaptedValues.withValue(\.testItem, item1) {
            #expect(MainActorAdaptedValues[\.testItem].value == 111)
            #expect(MainActorAdaptedValues[\.macroTestItem].value == defaultTestItemID)

            MainActorAdaptedValues.withValue(\.macroTestItem, macroItem) {
                #expect(MainActorAdaptedValues[\.testItem].value == 111)
                #expect(MainActorAdaptedValues[\.macroTestItem].value == 333)

                MainActorAdaptedValues.withValue(\.testItem, item2) {
                    #expect(MainActorAdaptedValues[\.testItem].value == 222)
                    #expect(MainActorAdaptedValues[\.macroTestItem].value == 333)
                }

                #expect(MainActorAdaptedValues[\.testItem].value == 111)
                #expect(MainActorAdaptedValues[\.macroTestItem].value == 333)
            }

            #expect(MainActorAdaptedValues[\.testItem].value == 111)
            #expect(MainActorAdaptedValues[\.macroTestItem].value == defaultTestItemID)
        }
    }

    @Test
    func withValuesMutation() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        let item = MainActorTestItem(value: 555)
        let macroItem = MainActorTestItem(value: 666)

        MainActorAdaptedValues.withValues {
            $0[override: \.testItem] = item
            $0[override: \.macroTestItem] = macroItem
        } operation: {
            #expect(MainActorAdaptedValues[\.testItem].value == 555)
            #expect(MainActorAdaptedValues[\.macroTestItem].value == 666)
        }

        #expect(MainActorAdaptedValues[\.testItem].value == defaultTestItemID)
        #expect(MainActorAdaptedValues[\.macroTestItem].value == defaultTestItemID)
    }

    @Test
    func typedThrowsSupport() {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        let item = MainActorTestItem(value: 777)

        let nonThrowingResult: Int = MainActorAdaptedValues.withValue(\.testItem, item) {
            #expect(MainActorAdaptedValues[\.testItem].value == 777)
            return 42
        }
        #expect(nonThrowingResult == 42)

        #expect(throws: TestCustomError.somethingWrong) {
            try MainActorAdaptedValues.withValue(\.testItem, item) { () throws(TestCustomError) in
                #expect(MainActorAdaptedValues[\.testItem].value == 777)
                throw TestCustomError.somethingWrong
            }
        }

        #expect(throws: TestCustomError.somethingWrong) {
            try MainActorAdaptedValues.withValues {
                $0[override: \.testItem] = item
            } operation: { () throws(TestCustomError) in
                #expect(MainActorAdaptedValues[\.testItem].value == 777)
                throw TestCustomError.somethingWrong
            }
        }
    }

    @Test
    func asyncWithValue() async throws {
        Adaption.mainActorStorage = MainActorAdaptedValueStorage()
        defer { Adaption.mainActorStorage = MainActorAdaptedValueStorage() }

        let item = MainActorTestItem(value: 888)

        await MainActorAdaptedValues.withValue(\.testItem, item) {
            try? await Task.sleep(nanoseconds: 10_000_000)
            #expect(MainActorAdaptedValues[\.testItem].value == 888)
        }

        #expect(MainActorAdaptedValues[\.testItem].value == defaultTestItemID)
    }
}
