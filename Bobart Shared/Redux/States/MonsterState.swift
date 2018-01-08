//
//  MonsterState.swift
//  Bobart
//
//  Created by james bouker on 11/25/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

struct MonsterState: Codable, StateType {
    var meta: MonsterMeta
    var loc: MapLocation
    var asset: String
    var hp: Int
    var index: Int
    var facing: Direction
    var hitDirection: Direction?

    init(meta: MonsterMeta, index: Int) {
        loc = MapLocation(x: 1, y: 1)
        asset = meta.asset
        hp = meta.maxHp
        facing = .l
        self.index = index
        self.meta = meta
    }
}
