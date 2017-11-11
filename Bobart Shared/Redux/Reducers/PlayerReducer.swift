//
//  PlayerReducer.swift
//  Bobart
//
//  Created by james bouker on 11/8/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

private func initialPlayerState(_ map: MapState) -> PlayerState {
    let location = map.noWallsOrItems.randomItem()
    return PlayerState(loc: location!)
}

private func movePlayer(_ action: PlayerAction, next: inout PlayerState) {
    switch action {
    case .moveUp: next.loc.y += 1
    case .moveDown: next.loc.y -= 1
    case .moveRight: next.loc.x += 1
    case .moveLeft: next.loc.x -= 1
    default: break
    }
}

private func playerReducer(_ action: PlayerAction, _ state: PlayerState, _ map: inout MapState) -> PlayerState {

    if action == .loadNextLevel {
        return initialPlayerState(map)
    }

    var next = state
    movePlayer(action, next: &next)

    // Check if player can move!
    if map.walls.contains(next.loc) {
        return state
    }

    // Check if hitting switch!
    if map.switchLoc == next.loc {
        if !map.switchHit {
            map.switchHit = true
            let stairLoc = map.noWallsOrItems.filter { $0 != state.loc }.randomItem()
            map.stairLoc = stairLoc!
        }
        return state
    }

    // Check if hitting chest!
    if map.chestLoc == next.loc {
        if !map.chestOpened {
            map.chestOpened = true
        }
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
