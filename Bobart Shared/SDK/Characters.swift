//
//  Characters.swift
//  1 Bit Rogue
//
//  Created by james bouker on 8/4/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

enum Character: String {
    case wizard

    case armor
    case ghost
    case slime
    case bat
    case bear
    case rat
    case worm
    case skeleton
    case dragon
}

enum Direction: String, Codable {
    case u
    case d
    case l
    case r

    init(facing: MapLocation) {
        let direction = facing.normalized
        switch direction {
        case MapLocation(x: 0, y: 0):
            self = .l
        case MapLocation(x: 1, y: 0):
            self = .r
        case MapLocation(x: -1, y: 0):
            self = .l
        case MapLocation(x: 0, y: 1):
            self = .u
        case MapLocation(x: 0, y: -1):
            self = .d
        default:
            self = .l
        }
    }

    var reversed: Direction {
        return Direction(facing: loc * -1)
    }

    var loc: MapLocation {
        switch self {
        case .u: return .init(x: 0, y: 1)
        case .d: return .init(x: 0, y: -1)
        case .l: return .init(x: -1, y: 0)
        case .r: return .init(x: 1, y: 0)
        }
    }

    static func all() -> [Direction] {
        return [.u, .d, .l, .r]
    }
}

extension Character {
    func animFrames(_ direction: Direction? = nil) -> SKAction {
        return .twoFrameAnim(pixelatedFile: rawValue, direction: direction?.rawValue)
    }
}
