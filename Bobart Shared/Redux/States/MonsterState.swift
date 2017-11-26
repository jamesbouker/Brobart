//
//  MonsterState.swift
//  Bobart
//
//  Created by james bouker on 11/25/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

struct MonsterState: Codable, StateType {
    //    var facing: Direction
    var loc: MapLocation
    var asset: String
    var hp: Int
    //    var hitDirection: Direction?
}
