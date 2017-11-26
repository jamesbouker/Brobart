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

    let width = levelMeta.randWidth
    let height = levelMeta.randHeight
    let maker = MazeMaker(width, height)
    let thinner = MazeThinner(width: width, height: height)
    let ones = maker.generate()
    let wallCount = ones.reduce(0) { $0 + $1 }
    let map = thinner.thinMaze(onesAndZeroes: maker.generate())
    let walls = map.keys.map { MapLocation(x: $0.x, y: $0.y) }
    if walls.count == wallCount {
        return randomMapState(level: level)
    }

    let mapState = MapState(level: level,
                            width: width,
                            height: height,
                            walls: walls,
                            env: levelMeta.atlas,
                            grass: levelMeta.grass,
                            torches: levelMeta.torches)
    return mapState ?? randomMapState(level: level)
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
