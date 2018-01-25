//
//  MonsterReducer.swift
//  Bobart
//
//  Created by james bouker on 11/25/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

func monstersForLevel(level levelNum: Int, map: MapState, player: PlayerState) -> [MonsterState] {
    var monsters = [MonsterState]()
    let level = LevelMeta.levelMeta(level: levelNum)

    // Must Spawns
    var monsterPlacementSoFar = [MapLocation]()
    let noWalls = map.noWallsOrItems

    var index = 0
    for monsterId in level.mustSpawn {
        let meta = MonsterMeta.monsterMeta(monsterId: monsterId)
        var monster = MonsterState(meta: meta, index: index)
        index += 1
        monster.loc = noWalls.notIncluding(monsterPlacementSoFar).notIncluding([player.loc]).randomItem()!
        monsterPlacementSoFar.append(monster.loc)
        monsters.append(monster)
    }

    // Can Spawn
    var canSpawns = [String]()
    for (monsterId, weight) in zip(level.canSpawn, level.spawnWeight) {
        for _ in 0 ..< weight {
            canSpawns.append(monsterId)
        }
    }

    let willSpawn = Int.random(min: level.minSpawn, max: level.maxSpawn)
    for _ in 0 ..< willSpawn {
        let monsterId = canSpawns[Int.random(canSpawns.count)]
        let meta = MonsterMeta.monsterMeta(monsterId: monsterId)
        var monster = MonsterState(meta: meta, index: index)
        index += 1
        monster.loc = noWalls.notIncluding(monsterPlacementSoFar).notIncluding([player.loc]).randomItem()!
        monsterPlacementSoFar.append(monster.loc)
        monsters.append(monster)
    }

    return monsters
}

private func removeWalls(_ locs: [MapLocation], wallItemMap: [MapLocation: Bool]) -> [MapLocation] {
    var foundWall = false
    var locations = [MapLocation]()

    for loc in locs.enumerated() {
        if foundWall || wallItemMap.hasKey(loc.element) {
            foundWall = true
        } else {
            locations.append(loc.element)
        }
    }
    return locations
}

private func visibleLocations(monster: MonsterState, range: Int, wallItemMap: [MapLocation: Bool]) -> [MapLocation] {
    let numbers = Array(1 ... range)

    var northLocations = numbers.map { MapLocation(x: monster.loc.x, y: monster.loc.y + $0) }
    northLocations = removeWalls(northLocations, wallItemMap: wallItemMap)

    var southLocations = numbers.map { MapLocation(x: monster.loc.x, y: monster.loc.y - $0) }
    southLocations = removeWalls(southLocations, wallItemMap: wallItemMap)

    var westLocations = numbers.map { MapLocation(x: monster.loc.x - $0, y: monster.loc.y) }
    westLocations = removeWalls(westLocations, wallItemMap: wallItemMap)

    var eastLocations = numbers.map { MapLocation(x: monster.loc.x + $0, y: monster.loc.y) }
    eastLocations = removeWalls(eastLocations, wallItemMap: wallItemMap)

    return northLocations + southLocations + westLocations + eastLocations
}

private func canShootPlayer(_ monster: MonsterState,
                            _ wallItemMap: [MapLocation: Bool],
                            _ player: PlayerState) -> MapLocation? {
    guard canReachPlayer(monster, wallItemMap, player, monster.meta.attackRange) != nil else {
        return nil
    }
    return player.loc
}

private func canSeePlayer(_ monster: MonsterState,
                          _ wallItemMap: [MapLocation: Bool],
                          _ player: PlayerState) -> MapLocation? {
    return canReachPlayer(monster, wallItemMap, player, monster.meta.sightRange)
}

private func canReachPlayer(_ monster: MonsterState,
                            _ wallItemMap: [MapLocation: Bool],
                            _ player: PlayerState,
                            _ range: Int) -> MapLocation? {
    guard
        player.loc.inLine(monster.loc) &&
        (player.loc - monster.loc).length <= range else {
        return nil
    }
    let visibles = visibleLocations(monster: monster, range: range, wallItemMap: wallItemMap)
    if visibles.contains(player.loc) {
        return (player.loc - monster.loc).normalized + monster.loc
    }
    return nil
}

func moveMonsters(monsters: [MonsterState], map: MapState, player: inout PlayerState) -> [MonsterState] {

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

        nextMonsters[i].hitDirection = nil
        guard monster.hp > 0 && monster.blocked == false && monster.swapped == false else {
            continue
        }

        // Remove the current location from the map!
        monsterLocMap.removeValue(forKey: monster.loc)
        var nextLoc = canShootPlayer(monster, wallItemMap, player) ??
            canSeePlayer(monster, wallItemMap, player)

        if nextLoc == nil || monsterLocMap.hasKey(nextLoc!) {
            // Find next possible spots
            var possibleNextMove = monster.loc.adjacents.inBounds(width: map.width, height: map.height)
            possibleNextMove.filtered {
                !monsterLocMap.hasKey($0)
            }

            // If can't fly, remove walls from next moves
            if monster.meta.canFly != true {
                possibleNextMove = possibleNextMove.filter {
                    !wallItemMap.hasKey($0)
                }
            }

            // Grab the next location, if missing don't move
            nextLoc = possibleNextMove.randomItem()
        }

        var loc = nextLoc ?? nextMonsters[i].loc
        nextMonsters[i].facing = Direction(facing: loc - monster.loc)

        // check if hitting the player
        if player.loc == nextLoc {
            player.hp -= monster.meta.attack
            nextMonsters[i].hitDirection = Direction(facing: player.loc - monster.loc)
            loc = monsters[i].loc
        }

        // Update map and the next monster location
        nextMonsters[i].loc = loc
        monsterLocMap[loc] = true
    }

    // return them with original index based sort
    return nextMonsters.sorted {
        $0.index < $1.index
    }
}

func monsterReducer(action: Action,
                    state: [MonsterState]?,
                    map: MapState,
                    player: inout PlayerState)
    -> [MonsterState] {

    guard let next = state else {
        return monstersForLevel(level: 1, map: map, player: player)
    }
    guard let action = action as? PlayerAction else {
        return next
    }

    if action == .loadNextLevel {
        return monstersForLevel(level: map.level, map: map, player: player)
    }
    return moveMonsters(monsters: next, map: map, player: &player)
}
