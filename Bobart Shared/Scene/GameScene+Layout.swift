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
        var numberOfTorches = mapState.meta.torches

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

    func blankOut(_ loc: MapLocation) {
        items.setTile(TileType.blank, loc: loc)
        grass.setTile(TileType.blank, loc: loc)
        sfx.setTile(TileType.blank, loc: loc)
        sfx.setTile(TileType.blank, loc: loc.upOne)
    }

    func renderItem(test: Bool, left: [String], right: [String], loc: MapLocation) {
        blankOut(loc)

        let itemName = left.first!
        tileMap.childNode(withName: itemName)?.removeFromParent()

        let textureNames = test ? left : right
        let textures = textureNames.map { SKTexture.pixelatedImage(file: $0) }
        let node = SKSpriteNode(texture: textures.first!, color: .white, size: tileSize)
        node.name = itemName
        node.anchorPoint = .zero
        node.position = loc.point * tileLength
        tileMap.rePosition(node)
        node.zPosition -= 0.5
        tileMap.addChild(node)

        if textures.count > 1 {
            let action = SKAction.animate(with: textures, timePerFrame: frameTime)
            node.run(.repeatForever(action), type: ActionType.idle)
        }
    }

    func renderSwitch(mapState: MapState) {
        renderItem(test: mapState.switchHit,
                   left: [Assets.switch_right],
                   right: [Assets.switch_left],
                   loc: mapState.switchLoc)
    }

    func renderFire(mapState: MapState) {
        tileMap.childNode(withName: Assets.fire_1)?.removeFromParent()
        if let loc = mapState.fireLoc {
            renderItem(test: mapState.fireHit,
                       left: [Assets.fire_1, Assets.fire_2],
                       right: [Assets.fire_out],
                       loc: loc)
        }
    }

    func renderChest(mapState: MapState) {
        renderItem(test: mapState.chestOpened,
                   left: [Assets.chest_empty],
                   right: [Assets.chest_closed],
                   loc: mapState.chestLoc)
    }

    func renderStairs(mapState: MapState) {
        if mapState.switchHit {
            tileMap.setTile(TileType.stairs_down_solo,
                            loc: mapState.stairLoc,
                            atlas: mapState.environment.rawValue)

            grass.setTile(TileType.blank, loc: mapState.stairLoc)
            shadows.setTile(TileType.blank, loc: mapState.stairLoc)
            sfx.setTile(TileType.blank, loc: mapState.stairLoc)
            sfx.setTile(TileType.blank, loc: mapState.stairLoc.upOne)
        }
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
            node.position = loc.point * tileLength
            self.monsters.append(node)
            tileMap.addChild(node)
            tileMap.rePosition(node)
        }
    }

    func removeFood() {
        tileMap.enumerateChildNodes(withName: "food") { node, _ in
            node.removeFromParent()
        }
    }

    func renderFood(map: MapState) {
        removeFood()

        let foodMap = map.foodLocations.toDictionary { $0 }
        for (loc, _) in foodMap {
            let foodCount = map.foodLocations.filter { $0 == loc }.count
            foodNode(loc: loc, count: foodCount)
        }
    }
}

extension GameScene {

    func layout(to: GameState, from: GameState?) {
        let playerState = to.playerState
        let mapState = to.mapState
        let noWalls = to.mapState.noWalls
        let grassMax = to.mapState.meta.grass

        sharedController.setHp(current: playerState.hp, max: playerState.maxHp)
        sharedController.setFloor(to.mapState.level)

        if from?.mapState.level != to.mapState.level {
            tileMap.tileSet = SKTileSet(named: to.mapState.environment.rawValue)!
            tileMap.pixelate()

            sharedController.setFood(playerState.food)
            resizeTheMap(mapState: mapState)
            renderWalls(mapState: mapState)
            renderGrass(grassMax: grassMax, noWalls: noWalls)
            renderSwitch(mapState: mapState)
            renderFire(mapState: mapState)
            renderStairs(mapState: mapState)
            renderChest(mapState: mapState)
            positionThePlayer(playerState: playerState)
            renderMonsters(monsters: to.monsterStates)
            renderFood(map: mapState)
            tileMap.rePosition(player)
            return
        }

        if from?.mapState.switchHit != to.mapState.switchHit {
            renderSwitch(mapState: mapState)
        }

        if from?.mapState.fireHit != to.mapState.fireHit {
            renderFire(mapState: mapState)
        }

        if from?.mapState.switchHit != to.mapState.switchHit {
            renderStairs(mapState: mapState)
        }

        if from?.mapState.chestOpened != to.mapState.chestOpened {
            renderChest(mapState: mapState)
        }

        for monster in monsters {
            tileMap.rePosition(monster)
        }
        tileMap.rePosition(player)
    }
}
