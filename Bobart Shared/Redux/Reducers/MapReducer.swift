//
//  MapReducer.swift
//  Bobart
//
//  Created by james bouker on 11/8/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

private func randomMapState() -> MapState {
    let width = Int.random(min: 5, max: 7)
    let height = Int.random(min: 5, max: 7)

    var walls = [MapLocation]()
    for i in 0 ..< width {
        walls.append(MapLocation(x: i, y: 0))
        walls.append(MapLocation(x: i, y: height - 1))
    }
    for i in 1 ..< height {
        walls.append(MapLocation(x: 0, y: i))
        walls.append(MapLocation(x: width - 1, y: i))
    }
    return MapState(width: width, height: height, walls: walls)
}

func mapReducer(action _: Action, state: MapState?) -> MapState {
    return state ?? randomMapState()
}
