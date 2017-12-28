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

    for monsterId in level.mustSpawn ?? [] {
        let meta = MonsterMeta.monsterMeta(monsterId: monsterId)
        var monster = MonsterState(meta: meta, loc: .init(x: 1, y: 1), asset: meta.asset, hp: meta.maxHp)
        monster.loc = noWalls.notIncluding(monsterPlacementSoFar).randomItem()!
        monsterPlacementSoFar.append(monster.loc)
        monsters.append(monster)
    }

    // Can Spawns
    // TODO:
    return monsters
}

func moveMonsters(monsters: [MonsterState], map: MapState, player _: PlayerState) -> [MonsterState] {
    //    let monsters = monsters.sorted { (one, two) -> Bool in
    //        let delta1 = player.loc - one.loc
    //        let delta2 = player.loc - two.loc
    //        return delta1.length < delta2.length
    //    }

    let wallItemMap = map.wallItemMap

    var nextMonsters = monsters
    for (i, monster) in monsters.enumerated() {
        let meta = monster.meta
        if meta.canFly ?? false {
            nextMonsters[i].loc = monster.loc.adjacents.randomItem()!
        } else {
            nextMonsters[i].loc = monster.loc.adjacents.filter {
                let wallThere = (wallItemMap[$0] ?? false)
                let inBounds = $0.x > 0 && $0.y > 0 && $0.x < map.width - 1 && $0.y < map.height - 1
                return !wallThere && inBounds
            }.randomItem()!
        }
    }
    return nextMonsters
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
