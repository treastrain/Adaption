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
        try ItemMacroExpansion.expansion(
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
            keyProtocolName: "AdaptionKey",
            invalidDeclaration: Error.onlyApplicableToAdaptedValuesExtension
        )
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
