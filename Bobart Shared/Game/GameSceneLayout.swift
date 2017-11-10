//
//  GameSceneLayout.swift
//  Bobart
//
//  Created by james bouker on 11/7/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import SpriteKit

fileprivate extension GameScene {
    func resizeTheMap(mapState: MapState) {
        tileMap.resetMaps()
        tileMap.numberOfRows = mapState.height
        tileMap.numberOfColumns = mapState.width
        tileMap.setAllTiles(tile: TileType.floor)
    }

    func addGrass(grassMax: Int, noWalls: [MapLocation]) {
        for _ in 0 ..< Int.random(grassMax) {
            if let loc = noWalls.randomItem() {
                grass.setTile(tile: TileType.grass, forLocation: loc)
            }
        }
    }

    func addWalls(walls: [MapLocation], map: [MapLocation: Bool]) {
        for wall in walls {
            let oneDown = MapLocation(x: wall.x, y: wall.y - 1)
            let isHorz = map[oneDown] == nil
            let tile = !isHorz ? TileType.vert_wall : TileType.horz_wall
            tileMap.setTile(tile: tile, forLocation: wall, atlas: Atlas.stone)

            if isHorz && wall.y > 0 {
                shadows.setTile(tile: TileType.shadow, forLocation: oneDown)

                if Int.random(100) < 20 {
                    sfx.setTile(tile: TileType.torch, forLocation: wall)
                    sfx.setTile(tile: TileType.torch_under, forLocation: oneDown)
                }
            }
        }
    }

    func addSwitch(mapState: MapState) {
        let switchTile = mapState.switchToggled ? TileType.switch_on : TileType.switch_off
        items.setTile(tile: switchTile, forLocation: mapState.switchLoc)
    }

    func addStairs(mapState: MapState) {
        if mapState.switchToggled {
            tileMap.setTile(tile: TileType.stairs_down_solo, forLocation: mapState.stairLoc, atlas: Atlas.stone)
            grass.setTile(tile: TileType.blank, forLocation: mapState.stairLoc)
            shadows.setTile(tile: TileType.blank, forLocation: mapState.stairLoc)
            sfx.setTile(tile: TileType.blank, forLocation: mapState.stairLoc)
        }
    }

    func positionThePlayer(playerState: PlayerState) {
        let loc = playerState.loc
        player.position = CGPoint(x: CGFloat(loc.x) * tileSize,
                                  y: CGFloat(loc.y) * tileSize)
    }
}

extension GameScene {
    func layout(state: GameState) {
        let playerState = state.playerState
        let mapState = state.mapState
        let map = mapState.wallMap
        let walls = state.mapState.walls
        let noWalls = state.mapState.noWalls
        let grassMax = noWalls.count / 2 + 1

        // ORDER IS IMPORTANT!
        resizeTheMap(mapState: mapState)
        addWalls(walls: walls, map: map)
        addGrass(grassMax: grassMax, noWalls: noWalls)
        addSwitch(mapState: mapState)
        addStairs(mapState: mapState)
        positionThePlayer(playerState: playerState)
    }
}
