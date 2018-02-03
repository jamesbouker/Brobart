//
//  MapLocation.swift
//  Bobart iOS
//
//  Created by james bouker on 11/7/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//
// swiftlint:disable shorthand_operator

import ReSwift
import UIKit

struct MapLocation: Codable, StateType {
    var x: Int
    var y: Int
}

extension Array where Element == MapLocation {
    func inBounds(width: Int, height: Int) -> [MapLocation] {
        return filter {
            $0.x > 0 && $0.y > 0 && $0.x < width - 1 && $0.y < height - 1
        }
    }

    func notIncluding(_ locs: [MapLocation]?) -> [MapLocation] {
        guard let locations = locs else {
            return self
        }
        return filter { !locations.contains($0) }
    }
}

extension MapLocation: Equatable, Hashable {

    var upOne: MapLocation {
        return MapLocation(x: x, y: y + 1)
    }

    var downOne: MapLocation {
        return MapLocation(x: x, y: y - 1)
    }

    var leftOne: MapLocation {
        return MapLocation(x: x - 1, y: y)
    }

    var rightOne: MapLocation {
        return MapLocation(x: x + 1, y: y)
    }

    var connecting: [MapLocation] {
        return [self.upOne, self.downOne, self.leftOne, self.rightOne]
    }

    var adjacents: [MapLocation] {
        return [self.upOne, self.downOne, self.leftOne, self.rightOne]
    }

    var point: CGPoint {
        return CGPoint(x: x, y: y)
    }

    static func == (lhs: MapLocation, rhs: MapLocation) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    static func - (lhs: MapLocation, rhs: MapLocation) -> MapLocation {
        return MapLocation(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func + (lhs: MapLocation, rhs: MapLocation) -> MapLocation {
        return MapLocation(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func += (lhs: inout MapLocation, rhs: MapLocation) {
        lhs = lhs + rhs
    }

    static func * (lhs: MapLocation, rhs: Int) -> MapLocation {
        return MapLocation(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    var hashValue: Int {
        return x ^ y
    }

    var length: Int {
        return abs(x) + abs(y)
    }

    func inLine(_ a: MapLocation) -> Bool {
        return a.x == x || a.y == y
    }

    var normalized: MapLocation {
        if x == 0 && y == 0 {
            return self
        }
        if abs(x) >= abs(y) {
            return MapLocation(x: x > 0 ? 1 : -1, y: 0)
        } else {
            return MapLocation(x: 0, y: y > 0 ? 1 : -1)
        }
    }
}
