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
    @Test(arguments: ["extension OtherValues", "extension Alias", "struct MainActorAdaptedValues"])
    func unsupportedContext(scope: String) {
        assertMacroExpansion(
            """
            \(scope) {
                @Item var item: Int = 0
            }
            """,
            expandedSource: """
                \(scope) {
                    var item: Int = 0
                }
                """,
            diagnostics: [
                .init(
                    message: "'@Item' macro can only attach to var declarations inside extensions of AdaptedValues or MainActorAdaptedValues",
                    line: 2,
                    column: 5
                )
            ],
            macroSpecs: ["Item": .init(type: ItemMacro.self)],
            failureHandler: { Issue.record(Comment(rawValue: $0.message)) }
        )
    }

    @Test(arguments: [
        "AdaptedValues",
        "MainActorAdaptedValues",
        "Adaption.AdaptedValues",
        "Adaption.MainActorAdaptedValues",
    ])
    func expansion(valuesName: String) {
        let mainActor = valuesName.hasSuffix("MainActorAdaptedValues")
        let keyName = mainActor ? "MainActorAdaptionKey" : "AdaptionKey"

        assertMacroExpansion(
            """
            extension \(valuesName) {
                @Item var item: any ItemProtocol = Example()
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
                "Item": .init(type: ItemMacro.self)
            ],
            failureHandler: { Issue.record(Comment(rawValue: $0.message)) }
        )
    }

    @Test(arguments: [false, true])
    func missingInitializer(mainActor: Bool) {
        let valuesName = mainActor ? "MainActorAdaptedValues" : "AdaptedValues"

        assertMacroExpansion(
            """
            extension \(valuesName) {
                @Item var item: Int
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
                    message: "'@Item' macro can only attach to var declarations inside extensions of AdaptedValues or MainActorAdaptedValues",
                    line: 2,
                    column: 5
                )
            ],
            macroSpecs: [
                "Item": .init(type: ItemMacro.self)
            ],
            failureHandler: { Issue.record(Comment(rawValue: $0.message)) }
        )
    }
}
