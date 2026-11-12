//
//  MainActorAdaptedValues+.swift
//  Adaption
//
//  Created by treastrain on 2026/11/13.
//

import Adaption
import Foundation

extension MainActorAdaptedValues {
    var testItem: any MainActorTestItemProtocol {
        get { Self[TestItemKey.self] }
        set { Self[TestItemKey.self] = newValue }
    }

    struct TestItemKey: MainActorAdaptionKey {
        static var defaultValue: any MainActorTestItemProtocol {
            MainActorTestItem(value: defaultTestItemID)
        }
    }

    @MainActorItem var macroTestItem: any MainActorTestItemProtocol =
        MainActorTestItem(value: defaultTestItemID)
}
