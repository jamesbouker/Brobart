//
//  MapState.swift
//  Bobart
//
//  Created by james bouker on 11/8/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

enum Environment: String, Codable {
    case stone
    case vine
    case sand
    case brick

    static var all: [Environment] {
        return [.stone, .vine, .sand, .brick]
    }

    static var random: Environment {
        let all = self.all
        return all[Int.random(all.count)]
    }
}

struct MapState: Codable, StateType {
    var level: Int
    var environment: Environment

    // Walls
    var width: Int
    var height: Int
    var walls: [MapLocation]

    // Chest
    var chestLoc: MapLocation
    var chestOpened: Bool

    // Stairs
    var stairLoc: MapLocation

    // Switch
    var switchLoc: MapLocation
    var switchHit: Bool

    init(level: Int, width: Int, height: Int, walls: [MapLocation], env: Environment) {
        self.level = level
        self.width = width
        self.height = height
        self.walls = walls
        environment = env
        switchLoc = .init(x: 0, y: 0)
        stairLoc = .init(x: 0, y: 0)
        chestLoc = .init(x: 0, y: 0)
        switchHit = false
        chestOpened = false

        // After everything initialized!
        switchLoc = noWalls.randomItem()!
        chestLoc = noWallsOrItems.randomItem()!
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
        return noWalls.filter { $0 != switchLoc && $0 != chestLoc }
    }

    var wallMap: [MapLocation: Bool] {
        return walls.toDictionary { $0 }.mapValues { _ in true }
    }
}
