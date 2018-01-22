//
//  LevelMeta.swift
//  Bobart
//
//  Created by james bouker on 11/11/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import Foundation

class LevelMeta: Codable {
    let mustSpawn: [String]?
    let canSpawn: [String]?
    let spawnWeight: [Int]?

    let minWidth: Int
    let maxWidth: Int
    let minHeight: Int
    let maxHeight: Int
    let grass: Int
    let torches: Int
    let wood: Float
    let atlas: Environment
}

extension LevelMeta {
    var randWidth: Int {
        var width = Int.random(min: minWidth, max: maxWidth)
        if width % 2 == 0 {
            width += (width == maxWidth ? -1 : 1)
        }
        return width
    }

    var randHeight: Int {
        var height = Int.random(min: minHeight, max: maxHeight)
        if height % 2 == 0 {
            height += (height == maxHeight ? -1 : 1)
        }
        return height
    }
}

extension LevelMeta {
    static var levels = [String: LevelMeta]()

    static func levelMeta(level: Int) -> LevelMeta {
        if levels.count > 0 {
            return levels["\(level)"]!
        }

        let decoder = JSONDecoder()
        let url = Bundle.main.url(forResource: "Levels", withExtension: "json")!
        let _data = try? Data(contentsOf: url)
        guard let data = _data else {
            fatalError("Could not load date from Levels.json")
        }
        let _levels: [String: LevelMeta]?
        _levels = try? decoder.decode([String: LevelMeta].self, from: data)
        guard let levels = _levels else {
            fatalError("Could not decode level.json")
        }
        self.levels = levels
        return levels["\(level)"]!
    }
}
