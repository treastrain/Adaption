//
//  ItemMacroTests.swift
//  Adaption
//
//  Created by treastrain on 2026/11/13.
//

import AdaptionMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing

struct ItemMacroTests {
    @Test(arguments: [false, true])
    func expansion(mainActor: Bool) {
        let macroName = mainActor ? "MainActorItem" : "Item"
        let valuesName = mainActor ? "MainActorAdaptedValues" : "AdaptedValues"
        let keyName = mainActor ? "MainActorAdaptionKey" : "AdaptionKey"

        assertMacroExpansion(
            """
            extension \(valuesName) {
                @\(macroName) var item: any ItemProtocol = Example()
            }
            """,
            expandedSource: """
                extension \(valuesName) {
                    var item: any ItemProtocol {
                        get {
                            Self[__Key_item.self]
                        }
                        set { Self[__Key_item.self] = newValue }
                    }

                    private struct __Key_item: \(keyName) {
                        typealias Value = any ItemProtocol
                        static var defaultValue: Value {
                            Example()
                        }
                    }
                }
                """,
            macroSpecs: [
                "Item": .init(type: ItemMacro.self),
                "MainActorItem": .init(type: MainActorItemMacro.self),
            ],
            failureHandler: { Issue.record(Comment(rawValue: $0.message)) }
        )
    }

    @Test(arguments: [false, true])
    func missingInitializer(mainActor: Bool) {
        let macroName = mainActor ? "MainActorItem" : "Item"
        let valuesName = mainActor ? "MainActorAdaptedValues" : "AdaptedValues"
        let diagnosticName = mainActor ? "MainActorItemMacro" : "Item"

        assertMacroExpansion(
            """
            extension \(valuesName) {
                @\(macroName) var item: Int
            }
            """,
            expandedSource: """
                extension \(valuesName) {
                    var item: Int {
                        get {
                            Self[__Key_item.self]
                        }
                        set { Self[__Key_item.self] = newValue }
                    }
                }
                """,
            diagnostics: [
                .init(
                    message: "'@\(diagnosticName)' macro can only attach to var declarations inside extensions of \(valuesName)",
                    line: 2,
                    column: 5
                )
            ],
            macroSpecs: [
                "Item": .init(type: ItemMacro.self),
                "MainActorItem": .init(type: MainActorItemMacro.self),
            ],
            failureHandler: { Issue.record(Comment(rawValue: $0.message)) }
        )
    }
}
