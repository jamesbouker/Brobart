//
//  MonsterMeta.swift
//  Bobart
//
//  Created by james bouker on 11/25/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import Foundation

struct MonsterMeta: Codable {
    var monsterId: String
    var maxHp: Int
    var asset: String
    var ai: String

    var isDirectional: Bool
    var onDeath: String?

    var range: Int?
    var shootRange: Int?
    var rangedItem: String?
}

extension MonsterMeta {
    static var monsters = [String: MonsterMeta]()

    static func monsterMeta(monsterId: String) -> MonsterMeta {
        if monsters.count > 0 {
            return monsters[monsterId]!
        }

        let decoder = JSONDecoder()
        let url = Bundle.main.url(forResource: "Monsters", withExtension: "json")!
        let _data = try? Data(contentsOf: url)
        guard let data = _data else {
            fatalError("Could not load date from Monsters.json")
        }
        let _monsters: [MonsterMeta]?
        _monsters = try? decoder.decode([MonsterMeta].self, from: data)
        guard let monsters = _monsters else {
            fatalError("Could not decode Monsters.json")
        }
        self.monsters = monsters.toDictionary { $0.monsterId }
        return self.monsters[monsterId]!
    }
}
