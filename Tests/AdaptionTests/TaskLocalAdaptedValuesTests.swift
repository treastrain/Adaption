//
//  TaskLocalAdaptedValuesTests.swift
//  Adaption
//
//  Created by treastrain on 2026/11/13.
//

import Foundation
import Testing

@testable import Adaption

@MainActor
@Suite(.tags(.values), .serialized)
struct TaskLocalAdaptedValuesTests {
    private struct Client {
        @Adaptor(shared: \.testItem) var item
    }

    private enum TestCustomError: Error, Equatable {
        case somethingWrong
    }

    @Test
    func priorityOverGlobal() {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        let globalItem = TestItem(value: 100)
        AdaptedValues[\.testItem] = globalItem
        #expect(AdaptedValues[\.testItem].value == 100)

        let localItem = TestItem(value: 200)
        AdaptedValues.withValue(\.testItem, localItem) {
            #expect(AdaptedValues[\.testItem].value == 200)
            #expect(AdaptedValues[\.testItem] === localItem)

            let client = Client()
            #expect(client.item.value == 200)
            #expect(client.item === localItem)
        }

        #expect(AdaptedValues[\.testItem].value == 100)
        #expect(AdaptedValues[\.testItem] === globalItem)
    }

    @Test
    func directTaskLocalCurrentWithValue() {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        let globalItem = TestItem(value: 100)
        AdaptedValues[\.testItem] = globalItem

        var values = AdaptedValues()
        let localItem = TestItem(value: 300)
        values[override: \.testItem] = localItem

        AdaptedValues.$current.withValue(values) {
            #expect(AdaptedValues[\.testItem].value == 300)
            #expect(AdaptedValues[\.testItem] === localItem)
        }

        #expect(AdaptedValues[\.testItem].value == 100)
    }

    @Test
    func withValueByKeyType() {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        let localItem = TestItem(value: 400)
        AdaptedValues.withValue(AdaptedValues.TestItemKey.self, localItem) {
            #expect(AdaptedValues[AdaptedValues.TestItemKey.self].value == 400)
            #expect(AdaptedValues[\.testItem].value == 400)
        }

        #expect(AdaptedValues[\.testItem].value == defaultTestItemID)
    }

    @Test
    func nestedWithValue() {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        let item1 = TestItem(value: 111)
        let item2 = TestItem(value: 222)
        let macroItem = TestItem(value: 333)

        AdaptedValues.withValue(\.testItem, item1) {
            #expect(AdaptedValues[\.testItem].value == 111)
            #expect(AdaptedValues[\.macroTestItem].value == defaultTestItemID)

            AdaptedValues.withValue(\.macroTestItem, macroItem) {
                #expect(AdaptedValues[\.testItem].value == 111)
                #expect(AdaptedValues[\.macroTestItem].value == 333)

                AdaptedValues.withValue(\.testItem, item2) {
                    #expect(AdaptedValues[\.testItem].value == 222)
                    #expect(AdaptedValues[\.macroTestItem].value == 333)
                }

                #expect(AdaptedValues[\.testItem].value == 111)
                #expect(AdaptedValues[\.macroTestItem].value == 333)
            }

            #expect(AdaptedValues[\.testItem].value == 111)
            #expect(AdaptedValues[\.macroTestItem].value == defaultTestItemID)
        }
    }

    @Test
    func withValuesMutation() {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        let item = TestItem(value: 555)
        let macroItem = TestItem(value: 666)

        AdaptedValues.withValues {
            $0[override: \.testItem] = item
            $0[override: \.macroTestItem] = macroItem
        } operation: {
            #expect(AdaptedValues[\.testItem].value == 555)
            #expect(AdaptedValues[\.macroTestItem].value == 666)
        }

        #expect(AdaptedValues[\.testItem].value == defaultTestItemID)
        #expect(AdaptedValues[\.macroTestItem].value == defaultTestItemID)
    }

    @Test
    func typedThrowsSupport() {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        let item = TestItem(value: 777)

        let nonThrowingResult: Int = AdaptedValues.withValue(\.testItem, item) {
            #expect(AdaptedValues[\.testItem].value == 777)
            return 42
        }
        #expect(nonThrowingResult == 42)

        #expect(throws: TestCustomError.somethingWrong) {
            try AdaptedValues.withValue(\.testItem, item) { () throws(TestCustomError) in
                #expect(AdaptedValues[\.testItem].value == 777)
                throw TestCustomError.somethingWrong
            }
        }

        #expect(throws: TestCustomError.somethingWrong) {
            try AdaptedValues.withValues {
                $0[override: \.testItem] = item
            } operation: { () throws(TestCustomError) in
                #expect(AdaptedValues[\.testItem].value == 777)
                throw TestCustomError.somethingWrong
            }
        }
    }

    @Test
    func asyncWithValueConcurrency() async throws {
        Adaption.storage = AdaptedValueStorage()
        defer { Adaption.storage = AdaptedValueStorage() }

        AdaptedValues[\.testItem] = TestItem(value: 0)

        await withTaskGroup(of: Void.self) { group in
            for i in 1...20 {
                group.addTask {
                    let taskItem = TestItem(value: i)
                    await AdaptedValues.withValue(\.testItem, taskItem) {
                        try? await Task.sleep(nanoseconds: 10_000_000)
                        #expect(AdaptedValues[\.testItem].value == i)
                    }
                }
            }
        }

        #expect(AdaptedValues[\.testItem].value == 0)
    }
}
