//
//  RangedItemMeta.swift
//  Bobart
//
//  Created by james bouker on 1/16/18.
//  Copyright © 2018 JimmyBouker. All rights reserved.
//

import Foundation

class RangedItemMeta: Codable {
    let id: String
    let frames: Int
    let asset: String
    let directional: Bool
}

extension RangedItemMeta {
    static var items = [String: RangedItemMeta]()

    static func rangedItemMeta(id: String) -> RangedItemMeta {
        if items.count > 0 {
            return items[id]!
        }

        let decoder = JSONDecoder()
        let url = Bundle.main.url(forResource: "RangedItems", withExtension: "json")!
        let _data = try? Data(contentsOf: url)
        guard let data = _data else {
            fatalError("Could not load date from RangedItems.json")
        }
        let _items: [RangedItemMeta]?
        _items = try? decoder.decode([RangedItemMeta].self, from: data)
        guard let items = _items else {
            fatalError("Could not decode RangedItems.json")
        }
        self.items = items.toDictionary { $0.id }
        return self.items[id]!
    }
}
