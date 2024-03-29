//
//  MonsterState.swift
//  Bobart
//
//  Created by james bouker on 11/25/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

struct MonsterState: Codable, StateType, Equatable, Hashable {
    var meta: MonsterMeta
    var uuid: String
    var loc: MapLocation
    var asset: String
    var hp: Int
    var index: Int
    var facing: Direction {
        didSet {
            if facing == .u || facing == .d {
                facing = oldValue
            }
        }
    }

    var hitDirection: Direction?
    var blocked: Bool
    var phased: Bool

    // If cannot see/hit player - move toward...
    var lastSawPlayer: MapLocation?

    init(meta: MonsterMeta, index: Int) {
        loc = MapLocation(x: 1, y: 1)
        asset = meta.asset
        hp = meta.maxHp
        facing = .l
        uuid = UUID().uuidString
        blocked = false
        phased = false
        self.index = index
        self.meta = meta
    }

    public var hashValue: Int {
        return uuid.hashValue
    }

    static func == (lhs: MonsterState, rhs: MonsterState) -> Bool {
        return lhs.index == rhs.index && lhs.uuid == rhs.uuid
    }
}
