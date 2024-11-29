//
//  Item.swift
//  Adaption
//
//  Created by treastrain on 2024/11/29.
//

@attached(accessor)
@attached(peer, names: prefixed(__Key_))
public macro Item() = #externalMacro(module: "AdaptionMacros", type: "ItemMacro")
