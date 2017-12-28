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
    //    var hitDirection: Direction?
}
