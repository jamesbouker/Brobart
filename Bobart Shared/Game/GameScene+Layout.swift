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
        tileMap.numberOfRows = mapState.height
        tileMap.numberOfColumns = mapState.width
        tileMap.resetMaps()
        tileMap.setAllTiles(tile: TileType.floor, atlas: mapState.environment.rawValue)
    }

    func renderGrass(grassMax: Int, noWalls: [MapLocation]) {
        for _ in 0 ..< Int.random(grassMax) {
            if let loc = noWalls.randomItem() {
                grass.setTile(TileType.grass, loc: loc)
            }
        }
    }

    func renderWalls(mapState: MapState) {
        let walls = mapState.walls
        let map = mapState.wallMap

        for wall in walls {
            let oneDown = MapLocation(x: wall.x, y: wall.y - 1)
            let isHorz = map[oneDown] == nil
            let tile = !isHorz ? TileType.vert_wall : TileType.horz_wall
            tileMap.setTile(tile, loc: wall, atlas: mapState.environment.rawValue)

            if isHorz && wall.y > 0 {
                shadows.setTile(TileType.shadow, loc: oneDown)

                if Int.random(100) < 20 {
                    sfx.setTile(TileType.torch, loc: wall)
                    sfx.setTile(TileType.torch_under, loc: oneDown)
                }
            }
        }
    }

    func renderSwitch(mapState: MapState) {
        let switchTile = mapState.switchHit ? TileType.switch_on : TileType.switch_off
        items.setTile(switchTile, loc: mapState.switchLoc)
    }

    func renderStairs(mapState: MapState) {
        if mapState.switchHit {
            tileMap.setTile(TileType.stairs_down_solo,
                            loc: mapState.stairLoc,
                            atlas: mapState.environment.rawValue)

            grass.setTile(TileType.blank, loc: mapState.stairLoc)
            shadows.setTile(TileType.blank, loc: mapState.stairLoc)
            sfx.setTile(TileType.blank, loc: mapState.stairLoc)
        }
    }

    func renderChest(mapState: MapState) {
        let chest = mapState.chestOpened ? TileType.chest_empty : TileType.chest_closed
        items.setTile(chest, loc: mapState.chestLoc)
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
        let noWalls = state.mapState.noWalls
        let grassMax = noWalls.count / 2 + 1

        // ORDER IS IMPORTANT!
        if viewModel.state?.mapState.level != state.mapState.level {
            tileMap.tileSet = SKTileSet(named: state.mapState.environment.rawValue)!
            resizeTheMap(mapState: mapState)
            renderWalls(mapState: mapState)
            renderGrass(grassMax: grassMax, noWalls: noWalls)
            positionThePlayer(playerState: playerState)
        }
        renderSwitch(mapState: mapState)
        renderStairs(mapState: mapState)
        renderChest(mapState: mapState)
    }
}
