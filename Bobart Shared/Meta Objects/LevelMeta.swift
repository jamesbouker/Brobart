//
//  LevelMeta.swift
//  Bobart
//
//  Created by james bouker on 11/11/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import Foundation

struct LevelMeta: Codable {
    var mustSpawn: [String]?
    var canSpawn: [String]?
    var spawnWeight: [Int]?

    var width: Int
    var widthVar: Int?
    var height: Int
    var heightVar: Int?
    var grass: Int
    var atlas: Environment
}

extension LevelMeta {
    var randWidth: Int {
        let min = width - (widthVar ?? 0)
        let max = width + (widthVar ?? 0)
        return Int.random(min: min, max: max)
    }

    var randHeight: Int {
        let min = height - (heightVar ?? 0)
        let max = height + (heightVar ?? 0)
        return Int.random(min: min, max: max)
    }
}

extension LevelMeta {
    static func levelMeta(level: Int) -> LevelMeta {
        let decoder = JSONDecoder()
        let url = Bundle.main.url(forResource: "Levels", withExtension: "json")!
        let data = try! Data.init(contentsOf: url)
        let levels: [String : LevelMeta]
        levels = try! decoder.decode([String : LevelMeta].self, from: data)
        return levels["\(level)"]!
    }
}

