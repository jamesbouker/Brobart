//
//  MapLocation.swift
//  Bobart iOS
//
//  Created by james bouker on 11/7/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

struct MapLocation: Codable, StateType {
    var x: Int
    var y: Int
}

extension MapLocation: Equatable, Hashable {
    static func ==(lhs: MapLocation, rhs: MapLocation) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
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
