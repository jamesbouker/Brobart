//
//  MapReducer.swift
//  Bobart
//
//  Created by james bouker on 11/8/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

private func randomMapState(level: Int) -> MapState {
    let levelMeta = LevelMeta.levelMeta(level: level)

    let width = 9// levelMeta.randWidth
    let height = 9//levelMeta.randHeight

    var walls = [MapLocation]()
    for i in 0 ..< width {
        walls.append(MapLocation(x: i, y: 0))
        walls.append(MapLocation(x: i, y: height - 1))
    }
    for i in 1 ..< height {
        walls.append(MapLocation(x: 0, y: i))
        walls.append(MapLocation(x: width - 1, y: i))
    }

//    var mazeGen = MazeGen.maze(width: width - 2, height: height - 2)
//    mazeGen = mazeGen.map { MapLocation(x: $0.x + 1, y: $0.y + 1) }
    walls = LevelCreator().levels.last!

    return MapState(level: level,
                    width: width,
                    height: height,
                    walls: walls,
                    env: levelMeta.atlas,
                    grass: levelMeta.grass,
                    torches: levelMeta.torches)
}

func mapReducer(action: Action, state: MapState?) -> MapState {
    if let action = action as? PlayerAction {
        if action == .loadNextLevel {
            let currentLevel = state?.level ?? 0
            return randomMapState(level: currentLevel + 1)
        }
    }
    return state ?? randomMapState(level: 1)
}
