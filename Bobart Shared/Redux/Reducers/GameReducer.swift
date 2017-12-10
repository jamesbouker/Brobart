//
//  GameReducer.swift
//  Bobart
//
//  Created by james bouker on 11/7/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

func gameReducer(action: Action, state: GameState?) -> GameState {
    var map = mapReducer(action: action, state: state?.mapState)
    let player = playerReducer(action: action, state: state?.playerState, map: &map)
    let monsters = monsterReducer(action: action, state: state?.monsterStates, map: map)
    return GameState(mapState: map, playerState: player, monsterStates: monsters)
}
