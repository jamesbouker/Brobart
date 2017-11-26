//
//  GameState.swift
//  Bobart
//
//  Created by james bouker on 11/7/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

struct GameState: Codable, StateType {
    var mapState: MapState
    var playerState: PlayerState
    var monsterStates: [MonsterState]
}
