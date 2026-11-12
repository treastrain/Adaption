//
//  MainActorItemMacro.swift
//  Adaption
//
//  Created by treastrain on 2026/11/12.
//

import Foundation
import SwiftCompilerPlugin
public import SwiftSyntax
import SwiftSyntaxBuilder
public import SwiftSyntaxMacros

public struct MainActorItemMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
            let binding = varDecl.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
        else {
            throw Error.onlyApplicableToMainActorAdaptedValuesExtension
        }

        return [
            AccessorDeclSyntax(
                stringLiteral: """
                    get { Self[__Key_\(identifier).self] }
                    set { Self[__Key_\(identifier).self] = newValue }
                    """
            )
        ]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
            let binding = varDecl.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
            let valueType = binding.typeAnnotation?.type,
            let initializerValue = binding.initializer?.value
        else {
            throw Error.onlyApplicableToMainActorAdaptedValuesExtension
        }

        return [
            DeclSyntax(
                stringLiteral: """
                    private struct __Key_\(identifier): MainActorAdaptionKey {
                        typealias Value = \(valueType)
                        static var defaultValue: Value { \(initializerValue) }
                    }
                    """
            )
        ]
    }
}

extension MainActorItemMacro {
    enum Error: Swift.Error, CustomStringConvertible {
        case onlyApplicableToMainActorAdaptedValuesExtension

        var description: String {
            switch self {
            case .onlyApplicableToMainActorAdaptedValuesExtension:
                "'@MainActorItemMacro' macro can only attach to var declarations inside extensions of MainActorAdaptedValues"
            }
        }
    }
}
