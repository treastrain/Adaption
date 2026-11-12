//
//  ItemMacro.swift
//  Adaption
//
//  Created by treastrain on 2024/11/29.
//

import Foundation
import SwiftCompilerPlugin
public import SwiftSyntax
import SwiftSyntaxBuilder
public import SwiftSyntaxMacros

public struct ItemMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard (try? keyProtocolName(in: context)) != nil else { return [] }
        return try ItemMacroExpansion.expansion(
            providingAccessorsOf: declaration,
            invalidDeclaration: Error.onlyApplicableToAdaptedValuesExtension
        )
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try ItemMacroExpansion.expansion(
            providingPeersOf: declaration,
            keyProtocolName: try keyProtocolName(in: context),
            invalidDeclaration: Error.onlyApplicableToAdaptedValuesExtension
        )
    }
}

extension ItemMacro {
    private static func keyProtocolName(in context: some MacroExpansionContext) throws -> String {
        guard let scope = context.lexicalContext.first(where: { $0.isProtocol((any DeclGroupSyntax).self) }),
            let extensionDecl = scope.as(ExtensionDeclSyntax.self)
        else {
            throw Error.onlyApplicableToAdaptedValuesExtension
        }

        let name: String
        if let identifier = extensionDecl.extendedType.as(IdentifierTypeSyntax.self) {
            name = identifier.name.text
        } else if let member = extensionDecl.extendedType.as(MemberTypeSyntax.self),
            let module = member.baseType.as(IdentifierTypeSyntax.self),
            module.name.text == "Adaption"
        {
            name = member.name.text
        } else {
            throw Error.onlyApplicableToAdaptedValuesExtension
        }

        switch name {
        case "AdaptedValues": return "AdaptionKey"
        case "MainActorAdaptedValues": return "MainActorAdaptionKey"
        default: throw Error.onlyApplicableToAdaptedValuesExtension
        }
    }

    enum Error: Swift.Error, CustomStringConvertible {
        case onlyApplicableToAdaptedValuesExtension

        var description: String {
            switch self {
            case .onlyApplicableToAdaptedValuesExtension:
                "'@Item' macro can only attach to var declarations inside extensions of AdaptedValues or MainActorAdaptedValues"
            }
        }
    }
}
