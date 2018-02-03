//
//  PlayerState.swift
//  Bobart
//
//  Created by james bouker on 11/8/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

struct PlayerState: Codable, StateType {
    var facing: Direction {
        didSet {
            if facing == .u || facing == .d {
                facing = oldValue
            }
        }
    }

    var loc: MapLocation
    var hitDirection: Direction?
    var hp: Int
    var maxHp: Int

    var food: Int
}
