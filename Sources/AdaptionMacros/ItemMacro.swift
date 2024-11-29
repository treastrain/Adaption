//
//  ItemMacro.swift
//  Adaption
//
//  Created by treastrain on 2024/11/29.
//

import Foundation
import SwiftCompilerPlugin
public import SwiftSyntax
public import SwiftSyntaxMacros

public struct ItemMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
        else {
            throw Error.onlyApplicableToAdaptedValuesExtension
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
            throw Error.onlyApplicableToAdaptedValuesExtension
        }
        
        return [
            DeclSyntax(
                stringLiteral: """
                    private struct __Key_\(identifier): AdaptionKey {
                        typealias Value = \(valueType)
                        static var defaultValue: Value { \(initializerValue) }
                    }
                    """
            )
        ]
    }
}

extension ItemMacro {
    enum Error: Swift.Error, CustomStringConvertible {
        case onlyApplicableToAdaptedValuesExtension
        
        var description: String {
            switch self {
            case .onlyApplicableToAdaptedValuesExtension:
                "'@Item' macro can only attach to var declarations inside extensions of AdaptedValues"
            }
        }
    }
}
