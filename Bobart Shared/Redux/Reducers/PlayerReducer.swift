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
    return PlayerState(facing: .l, loc: location!, hitDirection: nil, hp: startingHp, maxHp: startingHp)
}

private func movePlayer(_ action: PlayerAction, next: inout PlayerState) {
    switch action {
    case .moveUp:
        next.loc.y += 1
    case .moveDown:
        next.loc.y -= 1
    case .moveRight:
        next.loc.x += 1
        next.facing = .r
    case .moveLeft:
        next.loc.x -= 1
        next.facing = .l
    default: break
    }
}

private func playerReducer(_ action: PlayerAction,
                           _ state: PlayerState,
                           _ map: inout MapState,
                           _ monsters: inout [MonsterState]?) -> PlayerState {

    if action == .loadNextLevel {
        return initialPlayerState(map)
    }

    var next = state

    // Reset status
    next.hitDirection = nil
    monsters?.modifyEach { $1.blocked = false }

    guard next.hp > 0 else {
        return next
    }

    movePlayer(action, next: &next)
    let direction = Direction(facing: next.loc - state.loc)

    // Check if hitting switch!
    if map.switchLoc == next.loc {
        next.hitDirection = direction
        if !map.switchHit {
            map.switchHit = true
            let stairLoc = map.deadEndsNoItems.randomItem() ?? map.noWallsOrItems.randomItem()
            map.stairLoc = stairLoc!
        }
        next.loc = state.loc
    }

    // Check if hitting chest!
    if map.chestLoc == next.loc {
        next.hitDirection = direction
        if !map.chestOpened {
            map.chestOpened = true
        }
        next.loc = state.loc
    }

    // Check if hitting monster
    monsters?.modifyWhere({ $0.hp > 0 && $0.loc == next.loc }, to: {
        // check if blocked!
        if Float.random() <= $0.meta.block {
            $0.blocked = true
        } else {
            $0.hp -= 1
        }
        next.hitDirection = direction
        next.loc = state.loc
    })

    // Check if player can move!
    if map.walls.contains(next.loc) {
        next.loc = state.loc
    }

    return next
}

func playerReducer(action: Action,
                   state: PlayerState?,
                   map: inout MapState,
                   monsters: inout [MonsterState]?) -> PlayerState {
    var next = state ?? initialPlayerState(map)
    if let action = action as? PlayerAction {
        next = playerReducer(action, next, &map, &monsters)
    }
    return next
}
