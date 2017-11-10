//
//  Constants.swift
//  1 Bit Rogue
//
//  Created by james bouker on 8/2/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

typealias Completion = () -> Void

// Taken from GameScene.sks Base.tileSize and TileSet tile size
let tileSize: CGFloat = 48.0

// Amount of time between 2 key frame animations
let frameTime = 0.20


// MARK: - Tile types
enum TileType {
    static let floor = "floor"
    static let vert_wall = "vert_wall"
    static let horz_wall = "horz_wall"
    static let shadow = "shadow"
    static let torch = "torch"
    static let torch_under = "torch_under"
    static let grass = "grass"
    static let chest_closed = "chest_closed"
    static let chest_empty = "chest_empty"
    static let switch_off = "switch_off"
    static let switch_on = "switch_on"
}

enum Atlas {
    static let stone = "stone"
}

enum SceneNode {
    static let player = "Player"
    static let square = "square"
    static let sfx = "sfx"
    static let items = "Items"
    static let grass = "Grass"
    static let shadows = "Shadows"
    static let base = "Base"
}
