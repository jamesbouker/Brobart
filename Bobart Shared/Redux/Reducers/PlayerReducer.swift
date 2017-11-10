//
//  PlayerReducer.swift
//  Bobart
//
//  Created by james bouker on 11/8/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

private func initialPlayerState(_ map: MapState) -> PlayerState {
    guard let location = map.noWalls.randomItem() else {
        fatalError("Could not place player")
    }
    return PlayerState(loc: location)
}

private func playerReducer(_ action: PlayerAction, _ state: PlayerState, _ map: inout MapState) -> PlayerState {
    var next = state
    switch action {
    case .moveUp: next.loc.y += 1
    case .moveDown: next.loc.y -= 1
    case .moveRight: next.loc.x += 1
    case .moveLeft: next.loc.x -= 1
    default: break
    }

    // Check if player can move!
    if map.walls.contains(next.loc) {
        return state
    }

    // Check if hitting switch!
    if map.switchLoc == next.loc {
        map.switchToggled = true
        let stairLoc = map.noWalls.filter { $0 != state.loc }.randomItem()
        map.stairLoc = stairLoc!
        return state
    }

    return next
}

func playerReducer(action: Action, state: PlayerState?, map: inout MapState) -> PlayerState {
    var next = state ?? initialPlayerState(map)
    if let action = action as? PlayerAction {
        next = playerReducer(action, next, &map)
    }
    return next
}
