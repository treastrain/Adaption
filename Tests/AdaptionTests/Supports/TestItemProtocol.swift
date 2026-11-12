//
//  TestItemProtocol.swift
//  AdaptionTests
//
//  Created by treastrain on 2024/10/23.
//

import Foundation

protocol TestItemProtocol: AnyObject, Sendable {
    var value: Int { get }
}
