//
//  TileMapExtensions.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/31/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit
import ObjectiveC

extension SKTileMapNode {

    func rePosition(_ node: SKNode) {
        node.zPosition = CGFloat(numberOfRows) - node.position.y / tileLength
    }

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

    private func group(_ tile: String, atlas: String? = nil) -> SKTileGroup? {
        return tileSet.tileGroups.filter {
            var name = (atlas != nil) ? atlas! + "_" : ""
            name += tile
            return $0.name == name
        }.first
    }

    func setTile(_ tile: String, loc: MapLocation, atlas: String? = nil) {
        if let group = group(tile, atlas: atlas) {
            setTileGroup(group, forColumn: loc.x, row: loc.y)
        } else {
            setTileGroup(nil, forColumn: loc.x, row: loc.y)
        }
    }

    func setAllTiles(tile: String, atlas: String = "stone") {
        for x in 0 ..< numberOfColumns {
            for y in 0 ..< numberOfRows {
                setTile(tile, loc: .init(x: x, y: y), atlas: atlas)
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
