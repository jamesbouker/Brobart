//
//  MonsterReducer.swift
//  Bobart
//
//  Created by james bouker on 11/25/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

func initialMonsterState() -> [MonsterState] {
    var monsters = [MonsterState]()
    let level = LevelMeta.levelMeta(level: 1)

    // Must Spawns
    for spawn in level.mustSpawn ?? [] {
        let meta = MonsterMeta.monsterMeta(monsterId: spawn)
        let monster = MonsterState(loc: .init(x: 1, y: 1), asset: meta.asset, hp: meta.maxHp)
        monsters.append(monster)
    }

    // Can Spawns
    // TODO
    return monsters
}

func moveMonsters(monsters: [MonsterState]) -> [MonsterState]{
    var nextMonsters = monsters
    for (i, monster) in monsters.enumerated() {
        nextMonsters[i].loc = monster.loc.adjacents.randomItem()!
    }
    return nextMonsters
}

func monsterReducer(action: Action, state: [MonsterState]?, map: MapState) -> [MonsterState] {
    guard var next = state else {
        return initialMonsterState()
    }
    guard action is PlayerAction else {
        return next
    }

    next = moveMonsters(monsters: next)
    return next
}
