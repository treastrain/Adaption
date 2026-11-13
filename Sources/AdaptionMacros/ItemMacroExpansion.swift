//
//  ItemMacroExpansion.swift
//  Adaption
//
//  Created by treastrain on 2026/11/13.
//

import SwiftSyntax
import SwiftSyntaxBuilder

enum ItemMacroExpansion {
    static func expansion(
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        invalidDeclaration: any Error
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
            let binding = varDecl.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed
        else {
            throw invalidDeclaration
        }

        return [
            AccessorDeclSyntax(
                stringLiteral: "get { Self[__Key_\(identifier).self] }"
            ),
            AccessorDeclSyntax(
                stringLiteral: "set { Self[__Key_\(identifier).self] = newValue }"
            ),
        ]
    }

    static func expansion(
        providingPeersOf declaration: some DeclSyntaxProtocol,
        keyProtocolName: String,
        invalidDeclaration: any Error
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
            let binding = varDecl.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed,
            let initializerValue = binding.initializer?.value
        else {
            throw invalidDeclaration
        }

        guard let valueType = binding.typeAnnotation?.type else {
            let isolation = keyProtocolName == "MainActorAdaptionKey" ? "@MainActor " : ""
            return [
                DeclSyntax(
                    stringLiteral: """
                        private struct __Key_\(identifier): \(keyProtocolName) {
                            typealias Value = ValueWitness.Value
                            static var defaultValue: Value { ValueWitness().value }

                            \(isolation)protocol ValueType {
                                associatedtype Value
                                var value: Value { get }
                            }

                            \(isolation)struct ValueWitness: ValueType {
                                let value = \(initializerValue)
                            }
                        }
                        """
                )
            ]
        }

        return [
            DeclSyntax(
                stringLiteral: """
                    private struct __Key_\(identifier): \(keyProtocolName) {
                        typealias Value = \(valueType)
                        static var defaultValue: Value { \(initializerValue) }
                    }
                    """
            )
        ]
    }
}
