//
//  MapState.swift
//  Bobart
//
//  Created by james bouker on 11/8/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

struct MapState: Codable, StateType {
    var level: Int
    var width: Int
    var height: Int
    var walls: [MapLocation]

    // Items
    var stairLoc: MapLocation
    var switchLoc: MapLocation
    var switchToggled: Bool

    init(level: Int, width: Int, height: Int, walls: [MapLocation]) {
        self.level = level
        self.width = width
        self.height = height
        self.walls = walls
        self.switchLoc = .init(x: 0, y: 0)
        switchToggled = false
        stairLoc = .init(x: 0, y: 0)

        guard let switchLoc = noWalls.randomItem() else {
            fatalError("Cannot place switch!")
        }
        self.switchLoc = switchLoc
    }
}

// MARK: - Dynamic Variables
extension MapState {
    private var columns: [Int] { return Array(0 ..< width) }
    private var rows: [Int] { return Array(0 ..< height) }
    private var locations: [MapLocation] {
        return columns.cross(rows).map { MapLocation(x: $0.0, y: $0.1) }
    }

    var noWalls: [MapLocation] {
        return locations.filter { !walls.contains($0) }
    }

    var noWallsOrItems: [MapLocation] {
        return noWalls.filter { $0 != switchLoc }
    }

    var wallMap: [MapLocation: Bool] {
        return walls.toDictionary { $0 }.mapValues { _ in true }
    }
}
