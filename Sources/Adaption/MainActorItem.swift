//
//  MainActorItem.swift
//  Adaption
//
//  Created by treastrain on 2026/11/12.
//

@attached(accessor)
@attached(peer, names: prefixed(__Key_))
public macro MainActorItem() = #externalMacro(module: "AdaptionMacros", type: "MainActorItemMacro")
