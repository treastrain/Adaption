//
//  AdaptionPlugin.swift
//  Adaption
//
//  Created by treastrain on 2024/11/29.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct AdaptionPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        ItemMacro.self
    ]
}
