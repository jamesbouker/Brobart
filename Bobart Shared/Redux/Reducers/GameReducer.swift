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
    var monsters = state?.monsterStates

    var player = playerReducer(action: action,
                               state: state?.playerState,
                               map: &map,
                               monsters: &monsters)

    monsters = monsterReducer(action: action,
                              state: monsters,
                              map: map,
                              player: &player)

    return GameState(mapState: map, playerState: player, monsterStates: monsters!)
}
