//
//  MonsterReducer.swift
//  Bobart
//
//  Created by james bouker on 11/25/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

func monstersForLevel(level: Int, map: MapState) -> [MonsterState] {
    var monsters = [MonsterState]()
    let level = LevelMeta.levelMeta(level: level)

    // Must Spawns
    var monsterPlacementSoFar = [MapLocation]()
    let noWalls = map.noWallsOrItems

    var index = 0
    for monsterId in level.mustSpawn ?? [] {
        let meta = MonsterMeta.monsterMeta(monsterId: monsterId)
        var monster = MonsterState(meta: meta, index: index)
        index += 1
        monster.loc = noWalls.notIncluding(monsterPlacementSoFar).randomItem()!
        monsterPlacementSoFar.append(monster.loc)
        monsters.append(monster)
    }

    // Can Spawns
    // TODO:
    return monsters
}

func moveMonsters(monsters: [MonsterState], map: MapState, player: PlayerState) -> [MonsterState] {

    // Sort based on distance from player (Give closer monsters priority)
    let monsters = monsters.sorted {
        return (player.loc - $0.loc).length < (player.loc - $1.loc).length
    }

    // Create monster location map (To avoid walking on same tile)
    var monsterLocMap = [MapLocation: Bool]()
    for monster in monsters where monster.hp > 0 {
        monsterLocMap[monster.loc] = true
    }

    // Store this so we do not create the map every AI run
    let wallItemMap = map.wallItemMap

    var nextMonsters = monsters
    for (i, monster) in monsters.enumerated() {

        guard monster.hp > 0 else {
            continue
        }

        // Remove the current location from the map!
        monsterLocMap.removeValue(forKey: monster.loc)

        // Find next possible spots
        var possibleNextMove = monster.loc.adjacents.inBounds(width: map.width, height: map.height)
        possibleNextMove.filtered {
            monsterLocMap[$0] != true
        }
        if monster.meta.canFly != true {
            possibleNextMove = possibleNextMove.filter {
                !(wallItemMap[$0] ?? false)
            }
        }

        // Grab the next location, if missing don't move
        let nextLoc = possibleNextMove.randomItem() ?? nextMonsters[i].loc
        nextMonsters[i].loc = nextLoc
        switch (nextMonsters[i].loc - monster.loc).normalized {
        case MapLocation(x: 1, y: 0):
            nextMonsters[i].facing = .r
        case MapLocation(x: -1, y: 0):
            nextMonsters[i].facing = .l
        default:
            break
        }

        // Update our map
        monsterLocMap[nextLoc] = true
    }

    // return them with original index based sort
    return nextMonsters.sorted {
        $0.index < $1.index
    }
}

func monsterReducer(action: Action, state: [MonsterState]?, map: MapState, player: PlayerState) -> [MonsterState] {
    guard let next = state else {
        return monstersForLevel(level: 1, map: map)
    }
    guard let action = action as? PlayerAction else {
        return next
    }

    if action == .loadNextLevel {
        return monstersForLevel(level: map.level, map: map)
    }
    return moveMonsters(monsters: next, map: map, player: player)
}
