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
        try ItemMacroExpansion.expansion(
            providingAccessorsOf: declaration,
            invalidDeclaration: Error.onlyApplicableToMainActorAdaptedValuesExtension
        )
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try ItemMacroExpansion.expansion(
            providingPeersOf: declaration,
            keyProtocolName: "MainActorAdaptionKey",
            invalidDeclaration: Error.onlyApplicableToMainActorAdaptedValuesExtension
        )
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
