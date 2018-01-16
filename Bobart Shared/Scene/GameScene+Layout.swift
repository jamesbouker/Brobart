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
        var numberOfTorches = mapState.torches

        for wall in walls.shuffled() {
            let oneDown = MapLocation(x: wall.x, y: wall.y - 1)
            let isHorz = map[oneDown] == nil
            var tile = !isHorz ? TileType.vert_wall_no_neighbor : TileType.horz_wall_no_neighbor
            if !isHorz {
                // check for neighbors, if we have one, pull from the ok bucket
                if map[wall.leftOne] != nil || map[wall.rightOne] != nil {
                    tile = TileType.vert_wall
                }
            } else {
                // check for nighbor above?
                if map[wall.upOne] != nil {
                    tile = TileType.horz_wall
                }
            }
            tileMap.setTile(tile, loc: wall, atlas: mapState.environment.rawValue)

            if isHorz && wall.y > 0 {
                shadows.setTile(TileType.shadow, loc: oneDown)

                if Int.random(100) < 20 && numberOfTorches > 0 {
                    numberOfTorches -= 1
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
        player.position = CGPoint(x: CGFloat(loc.x) * tileLength,
                                  y: CGFloat(loc.y) * tileLength)
    }

    func renderMonsters(monsters: [MonsterState]) {
        for monster in self.monsters {
            monster.removeFromParent()
        }
        self.monsters.removeAll()

        for monster in monsters {
            let character = Character(rawValue: monster.asset)
            let node = SKSpriteNode(color: .red, size: tileSize)
            node.anchorPoint = .zero
            let monsterId = monster.meta.monsterId
            let direction: Direction? = MonsterMeta.monsterMeta(monsterId: monsterId).isDirectional ? .l : nil
            node.run(character!.animFrames(direction))
            let loc = monster.loc
            node.position = CGPoint(x: CGFloat(loc.x) * tileLength,
                                    y: CGFloat(loc.y) * tileLength)
            self.monsters.append(node)
            tileMap.addChild(node)
        }
    }
}

extension GameScene {
    func layout(state: GameState) {
        let playerState = state.playerState
        let mapState = state.mapState
        let noWalls = state.mapState.noWalls
        let grassMax = state.mapState.grass

        // ORDER IS IMPORTANT!
        if viewModel.state?.mapState.level != state.mapState.level {
            tileMap.tileSet = SKTileSet(named: state.mapState.environment.rawValue)!
            tileMap.pixelate()

            resizeTheMap(mapState: mapState)
            renderWalls(mapState: mapState)
            renderGrass(grassMax: grassMax, noWalls: noWalls)
            positionThePlayer(playerState: playerState)
            renderMonsters(monsters: state.monsterStates)
        }
        renderSwitch(mapState: mapState)
        renderStairs(mapState: mapState)
        renderChest(mapState: mapState)
    }
}
