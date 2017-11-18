//
//  MazeThinner.swift
//  MazeGen
//
//  Created by james bouker on 11/17/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import Foundation

struct Loc: Equatable, Hashable {
    var x: Int
    var y: Int

    static func ==(lhs: Loc, rhs: Loc) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    var hashValue: Int {
        return x ^ y
    }

    var upOne: Loc {
        return Loc(x: x, y: y+1)
    }
    var downOne: Loc {
        return Loc(x: x, y: y-1)
    }
    var leftOne: Loc {
        return Loc(x: x-1, y: y)
    }
    var rightOne: Loc {
        return Loc(x: x+1, y: y)
    }
    var adjacent: [Loc] {
        return [self.upOne, self.downOne, self.rightOne, self.leftOne]
    }
}

class MazeThinner {

    var width: Int
    var height: Int

    fileprivate var walls = [Loc]()
    fileprivate var wallMap = [Loc: Bool]()
    fileprivate var innerWallMap = [Loc: Bool]()

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    func thinMaze(onesAndZeroes: [Int]) -> [Loc: Bool] {
        createWallMap(onesAndZeroes: onesAndZeroes)
        let toRemove = max(max(width, height) / 3, 1)
        removeWalls(toRemove, walls: &walls)

        let components = findComponents()
        for component in components.enumerated() {
            let toRemove = component.element.count / 5
            var walls = component.element.keys.map { $0 }
            removeWalls(toRemove, walls: &walls)
        }

        return wallMap
    }
}

fileprivate extension MazeThinner {
    func findComponents() -> [[Loc: Bool]] {
        var globalVisited = [Loc: Bool]()
        var groups = [[Loc: Bool]]()

        for w in innerWallMap.keys {
            if globalVisited[w] == nil {
                var group = [Loc: Bool]()
                dfs(wall: w, group: &group)
                for l in group {
                    globalVisited[l.key] = true
                }
                groups.append(group)
            }
        }
        return groups
    }

    func dfs(wall: Loc, group: inout [Loc: Bool]) {
        if group[wall] != nil {
            return
        }
        group[wall] = true
        if innerWallMap[wall.leftOne] != nil {
            dfs(wall: wall.leftOne, group: &group)
        }
        if innerWallMap[wall.rightOne] != nil {
            dfs(wall: wall.rightOne, group: &group)
        }
        if innerWallMap[wall.upOne] != nil {
            dfs(wall: wall.upOne, group: &group)
        }
        if innerWallMap[wall.downOne] != nil {
            dfs(wall: wall.downOne, group: &group)
        }
    }

    func createWallMap(onesAndZeroes: [Int]) {
        for x in 0..<width {
            for y in 0..<height {
                if onesAndZeroes[(height-1-y) * width + x] == 1 {
                    let loc = Loc(x: x, y: y)
                    walls.append(loc)
                    wallMap[loc] = true

                    if loc.x > 0 && loc.x < width-1 && loc.y > 0 && loc.y < height-1 {
                        innerWallMap[loc] = true
                    }
                }
            }
        }
    }

    func removeWalls(_ toRemove: Int, walls: inout [Loc]) {
        if toRemove <= 0 {
            return
        }
        for _ in 0..<toRemove {
            // Filter out all walls that are creating a dead end!
            var filtered = walls.filter {
                let rightDeadEnd = wallMap[$0.rightOne] == nil && adjecentCount(loc: $0.rightOne, map: wallMap) == 3
                let leftDeadEnd = wallMap[$0.leftOne] == nil && adjecentCount(loc: $0.leftOne, map: wallMap) == 3
                let upDeadEnd = wallMap[$0.upOne] == nil && adjecentCount(loc: $0.upOne, map: wallMap) == 3
                let downDeadEnd = wallMap[$0.downOne] == nil && adjecentCount(loc: $0.downOne, map: wallMap) == 3
                return !(rightDeadEnd || leftDeadEnd || upDeadEnd || downDeadEnd)
            }

            // Filter out the outer wall
            filtered = filtered.filter {
                $0.x > 0 && $0.x < width-1 && $0.y > 0 && $0.y < height-1
            }

            // Filter out all non sandwich walls (in between two walls, either up and down, left and right)
            // AND if removed, do not create loners
            filtered = filtered.filter {
                (wallMap[$0.upOne] != nil && wallMap[$0.downOne] != nil
                    && (wallMap[$0.leftOne] == nil && wallMap[$0.rightOne] == nil)
                    && adjecentCount(loc: $0.upOne, map: wallMap) > 1 && adjecentCount(loc: $0.downOne, map: wallMap) > 1)
                    ||
                    (wallMap[$0.leftOne] != nil && wallMap[$0.rightOne] != nil
                        && (wallMap[$0.upOne] == nil && wallMap[$0.downOne] == nil)
                        && adjecentCount(loc: $0.leftOne, map: wallMap) > 1 && adjecentCount(loc: $0.rightOne, map: wallMap) > 1)
            }

            if let first = filtered.shuffled().first {
                wallMap[first] = nil
                innerWallMap[first] = nil
                if let ind = walls.index(of: first) {
                    walls.remove(at: ind)
                }
            }
        }
    }

    func adjecentCount(loc: Loc, map: [Loc: Bool]) -> Int {
        return loc.adjacent.reduce(0) {
            $0 + (map[$1] != nil ? 1 : 0)
        }
    }
}
