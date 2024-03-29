//
//  Constants.swift
//  1 Bit Rogue
//
//  Created by james bouker on 8/2/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

// Taken from GameScene.sks Base.tileSize and TileSet tile size
let tileLength: CGFloat = 48.0
let tileSize: CGSize = CGSize(width: 48, height: 48)

// Amount of time between 2 key frame animations
let frameTime = 0.20

let startingHp = 100

enum ActionType {
    static let idle = "idle"
}

enum ZPositions {
    static let droppedItems: CGFloat = 1
    static let projectiles: CGFloat = 500.0
    static let textFront: CGFloat = 1001.0
    static let textBack: CGFloat = 1000.0
}

// MARK: - Tile types
enum TileType {
    static let blank = "blank"
    static let floor = "floor"
    static let vert_wall = "vert_wall"
    static let vert_wall_no_neighbor = "vert_wall_no_neighbor"
    static let horz_wall_no_neighbor = "horz_wall_no_neighbor"
    static let horz_wall = "horz_wall"
    static let shadow = "shadow"
    static let torch = "torch"
    static let torch_under = "torch_under"
    static let grass = "grass"
    static let stairs_down_solo = "stairs_down_solo"
}

enum Assets {
    static let chest_closed = "chest_closed"
    static let chest_empty = "chest_empty"
    static let switch_off = "switch_off"
    static let switch_on = "switch_on"
    static let switch_left = "switch_left"
    static let switch_right = "switch_right"
    static let fire_out = "fire_out"
    static let fire_1 = "fire_1"
    static let fire_2 = "fire_2"
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
