//
//  PlayerState.swift
//  Bobart
//
//  Created by james bouker on 11/8/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

struct PlayerState: Codable, StateType {
    var facing: Direction
    var loc: MapLocation
    var hitDirection: Direction?
}
