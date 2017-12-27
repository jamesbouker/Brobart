//
//  MapLocation.swift
//  Bobart iOS
//
//  Created by james bouker on 11/7/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift
import UIKit

struct MapLocation: Codable, StateType {
    var x: Int
    var y: Int
}

extension Array where Element == MapLocation {
    func notIncluding(_ locs: [MapLocation]?) -> [MapLocation] {
        guard let locations = locs else {
            return self
        }
        return filter { locations.contains($0) }
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

    var hashValue: Int {
        return x ^ y
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
