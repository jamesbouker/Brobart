//
//  MonsterMeta.swift
//  Bobart
//
//  Created by james bouker on 11/25/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import Foundation

class MonsterMeta: Codable {
    let monsterId: String
    let maxHp: Int
    let asset: String
    let sightRange: Int
    let attackRange: Int
    let isDirectional: Bool
    let canFly: Bool
    let block: Float
    let smart: Bool
    let attack: Int

    // Optionals
    let onDeath: String?
    let rangedItem: String?
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
