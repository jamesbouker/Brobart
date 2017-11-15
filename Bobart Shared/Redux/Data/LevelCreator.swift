//
//  LevelManager.swift
//  Bobart
//
//  Created by james bouker on 11/13/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import Foundation

class LevelCreator {
    var levels = [[MapLocation]]()

    init() {
        let wall = "#"

        let url = Bundle.main.url(forResource: "Levels", withExtension: "txt")!
        let txt = (try? String.init(contentsOf: url))!

        let allLevelMeta = txt.components(separatedBy: "--")
        for levelMeta in allLevelMeta {

            var levelWalls = [MapLocation]()
            let rows = levelMeta.components(separatedBy: .newlines)
            let width = rows.first!.count
            let height = rows.count - 2

            for row in rows.enumerated() {
                for cell in row.element.enumerated() {
                    if "\(cell.element)" == wall {
                        levelWalls.append(MapLocation(x: cell.offset, y: height - row.offset))
                    }
                }
            }
            levels.append(levelWalls)
        }
    }
}
