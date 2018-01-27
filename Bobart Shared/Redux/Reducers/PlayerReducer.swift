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
                           _ next: inout PlayerState,
                           _ map: inout MapState,
                           _ monsters: inout [MonsterState]?) -> PlayerState {
    let state = next
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

    // Check if hitting fire
    if map.fireLoc == next.loc {
        next.hitDirection = direction
        if !map.fireHit {
            map.fireHit = true
        }
        next.loc = state.loc
    }

    // Check if hitting monster
    monsters?.modifyWhere({ $0.hp > 0 && $0.loc == next.loc }, to: {
        // check if blocked or phased
        if Float.random() <= $0.meta.block {
            $0.blocked = true
            next.hitDirection = direction
            next.loc = state.loc
        } else if Float.random() <= $0.meta.phase && map.noWallsOrItems.contains($0.loc) {
            $0.loc = state.loc
            $0.phased = true
            $0.facing = direction
            next.facing = direction.reversed
        } else {
            $0.hp -= 1
            next.hitDirection = direction
            next.loc = state.loc
        }
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
        if action == .loadNextLevel {
            return initialPlayerState(map)
        }

        // Reset status
        next.hitDirection = nil
        monsters?.modifyEach {
            $1.blocked = false
            $1.phased = false
        }

        guard next.hp > 0 else {
            return next
        }

        next = playerReducer(action, &next, &map, &monsters)
    }
    return next
}
