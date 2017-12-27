//
//  MonsterReducer.swift
//  Bobart
//
//  Created by james bouker on 11/25/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

func monstersForLevel(level: Int) -> [MonsterState] {
    var monsters = [MonsterState]()
    let level = LevelMeta.levelMeta(level: level)

    // Must Spawns
    for monsterId in level.mustSpawn ?? [] {
        let meta = MonsterMeta.monsterMeta(monsterId: monsterId)
        let monster = MonsterState(monsterId: meta.monsterId, loc: .init(x: 1, y: 1), asset: meta.asset, hp: meta.maxHp)
        monsters.append(monster)
    }

    // Can Spawns
    // TODO:
    return monsters
}

func moveMonsters(monsters: [MonsterState], map: MapState) -> [MonsterState] {
    let noWallsItems = map.noWallsOrItems

    var nextMonsters = monsters
    for (i, monster) in monsters.enumerated() {
        nextMonsters[i].loc = monster.loc.adjacents.notIncluding(noWallsItems).randomItem()!
    }
    return nextMonsters
}

func monsterReducer(action: Action, state: [MonsterState]?, map: MapState) -> [MonsterState] {
    guard let next = state else {
        return monstersForLevel(level: 1)
    }
    guard let action = action as? PlayerAction else {
        return next
    }

    if action == .loadNextLevel {
        return monstersForLevel(level: map.level)
    }
    return moveMonsters(monsters: next, map: map)
}
