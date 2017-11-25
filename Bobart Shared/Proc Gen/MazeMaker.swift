//
//  MazeMaker.swift
//  MazeGen
//
//  Created by james bouker on 11/17/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import Foundation

fileprivate enum D:Int {
    case north = 1
    case south = 2
    case east = 4
    case west = 8

    static var allDirections:[D] {
        return [D.north, D.south, D.east, D.west]
    }

    var opposite:D {
        switch self {
        case .north:
            return .south
        case .south:
            return .north
        case .east:
            return .west
        case .west:
            return .east
        }
    }

    var diff:(Int, Int) {
        switch self {
        case .north:
            return (0, -1)
        case .south:
            return (0, 1)
        case .east:
            return (1, 0)
        case .west:
            return (-1, 0)
        }
    }
}

class MazeMaker {
    private let x:Int
    private let y:Int
    private var maze:[[Int]]

    init(_ x:Int, _ y:Int) {
        self.x = (x-1)/2
        self.y = (y-1)/2
        let column = [Int](repeating: 0, count: y)
        self.maze = [[Int]](repeating: column, count: x)
        generateMaze(0, 0)
    }

    private func generateMaze(_ cx:Int, _ cy:Int) {
        var directions = D.allDirections
        directions.shuffle()
        for direction in directions {
            let (dx, dy) = direction.diff
            let nx = cx + dx
            let ny = cy + dy
            if inBounds(nx, ny) && maze[nx][ny] == 0 {
                maze[cx][cy] |= direction.rawValue
                maze[nx][ny] |= direction.opposite.rawValue
                generateMaze(nx, ny)
            }
        }
    }

    private func inBounds(_ testX:Int, _ testY:Int) -> Bool {
        return inBounds(value:testX, upper:self.x) && inBounds(value:testY, upper:self.y)
    }

    private func inBounds(value:Int, upper:Int) -> Bool {
        return (value >= 0) && (value < upper)
    }

    func generate() -> [Int] {
        let cellWidth = 1
        var walls = ""

        for j in 0..<y {
            // Draw top edge
            var topEdge = ""
            for i in 0..<x {
                topEdge += "#"
                topEdge += String(repeating: (maze[i][j] & D.north.rawValue) == 0 ? "#" : " ", count: cellWidth)
            }
            topEdge += "#"
            walls += topEdge
            walls += "\n"

            // Draw left edge
            var leftEdge = ""
            for i in 0..<x {
                leftEdge += (maze[i][j] & D.west.rawValue) == 0 ? "#" : " "
                leftEdge += String(repeating: " ", count: cellWidth)
            }
            leftEdge += "#"
            walls += leftEdge
            walls += "\n"
        }

        // Draw bottom edge
        var bottomEdge = ""
        for _ in 0..<x {
            bottomEdge += "#"
            bottomEdge += String(repeating: "#", count: cellWidth)
        }
        bottomEdge += "#"
        walls += bottomEdge

        return walls.filter { $0 != "\n" }.map {
            $0 == "#" ? 1 : 0
        }
    }
}
