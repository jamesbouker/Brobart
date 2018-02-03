//
//  Actions.swift
//  Bobart
//
//  Created by james bouker on 11/7/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

enum PlayerAction: UInt8, Codable, Action {
    case pressed
    case moveRight
    case moveLeft
    case moveUp
    case moveDown
    case loadNextLevel
}

extension PlayerAction {
    var delta: MapLocation {
        switch self {
        case .moveUp:
            return MapLocation(x: 0, y: 1)
        case .moveDown:
            return MapLocation(x: 0, y: -1)
        case .moveRight:
            return MapLocation(x: 1, y: 0)
        case .moveLeft:
            return MapLocation(x: -1, y: 0)
        default:
            return MapLocation(x: 0, y: 0)
        }
    }
}
