//
//  TileMapExtensions.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/31/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//
// swiftlint:disable shorthand_operator
// swiftlint:disable operator_whitespace
// swiftlint:disable line_length
// swiftlint:disable file_length

import SpriteKit
import ObjectiveC

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }

    static func +=(lhs: inout CGPoint, rhs: CGSize) {
        lhs = lhs + rhs
    }
}

extension SKTileMapNode {

    func resetMaps() {
        setAllTiles(tile: "blank")

        for child in children {
            if let map = child as? SKTileMapNode {
                map.numberOfRows = numberOfRows
                map.numberOfColumns = numberOfColumns
                map.position = .zero
                map.resetMaps()
            }
        }
    }

    func group(_ tile: String, atlas: String? = nil) -> SKTileGroup? {
        return tileSet.tileGroups.filter {
            var name = (atlas != nil) ? atlas! + "_" : ""
            name += tile
            return $0.name == name
        }.first
    }

    func setTile(tile: String, forLocation: MapLocation, atlas: String? = nil) {
        if let group = group(tile, atlas: atlas) {
            setTileGroup(group, forColumn: forLocation.x, row: forLocation.y)
        } else {
            setTileGroup(nil, forColumn: forLocation.x, row: forLocation.y)
        }
    }

    func setAllTiles(tile: String, atlas: String = "stone") {
        for x in 0 ..< numberOfColumns {
            for y in 0 ..< numberOfRows {
                setTile(tile: tile, forLocation: .init(x: x, y: y), atlas: atlas)
            }
        }
    }

    func set(value: Bool, forKey: String, tile: String, atlas: String = "stone") {
        let name = atlas + "_" + tile

        for g in tileSet.tileGroups {
            guard g.name == name else { continue }
            for r in g.rules {
                for def in r.tileDefinitions {
                    if def.userData == nil {
                        def.userData = NSMutableDictionary()
                    }
                    def.userData?.setValue(value, forKey: forKey)
                }
            }
        }
    }

    func pixelate() {
        _ = tileSet.tileGroups.map { (group) -> SKTileGroup in
            _ = group.rules.map({ (rule) -> SKTileGroupRule in
                _ = rule.tileDefinitions.map({ (def) -> SKTileDefinition in
                    _ = def.textures.map({ (texture) -> SKTexture in
                        texture.pixelate()
                        return texture
                    })
                    return def
                })
                return rule
            })
            return group
        }

        for child in children {
            if let map = child as? SKTileMapNode {
                map.pixelate()
            }
        }
    }

    var items: SKTileMapNode {
        guard let items = childNode(withName: "Items") as? SKTileMapNode else { fatalError("Missing Items") }
        return items
    }

    var shadows: SKTileMapNode {
        guard let shadows = childNode(withName: "Shadows") as? SKTileMapNode else { fatalError("Missing Shadows") }
        return shadows
    }

    var grass: SKTileMapNode {
        guard let grass = childNode(withName: "Grass") as? SKTileMapNode else { fatalError("Missing Grass") }
        return grass
    }

    var sfx: SKTileMapNode {
        guard let sfx = childNode(withName: "sfx") as? SKTileMapNode else { fatalError("Missing sfx") }
        return sfx
    }

    func mapPosition(fromLocation: MapLocation) -> CGPoint {
        let center = centerOfTile(atColumn: fromLocation.x, row: fromLocation.y)
        return center
    }

    func mapLocation(fromPosition: CGPoint) -> MapLocation {
        let row = tileRowIndex(fromPosition: fromPosition)
        let column = tileColumnIndex(fromPosition: fromPosition)
        return MapLocation(x: column, y: row)
    }
}

extension CGSize {
    static func *(lhs: CGSize, rhs: MapLocation) -> CGSize {
        return CGSize(width: lhs.width * CGFloat(rhs.x), height: lhs.height * CGFloat(rhs.y))
    }
}
