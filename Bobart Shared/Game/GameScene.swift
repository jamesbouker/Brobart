//
//  GameScene.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/29/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit
import ReSwift

class GameScene: SKScene {

    var tileMap: SKTileMapNode!
    var shadows: SKTileMapNode!
    var grass: SKTileMapNode!
    var items: SKTileMapNode!
    var sfx: SKTileMapNode!

    var player: SKSpriteNode!
    var playerSquare: SKShapeNode!

    var monsters = [SKSpriteNode]()

    // MARK: - States
    var viewModel: GameSceneModel!

    #if os(watchOS)
        override func sceneDidLoad() { setupView() }
    #else
        override func didMove(to _: SKView) { setupView() }
    #endif
    func setupView() {
        grabOutlets()
        viewModel = GameSceneModel(layout: layout, anim: animate)
        viewModel.subscribe()
    }

    func grabOutlets() {
        tileMap = childNode(withName: SceneNode.base) as? SKTileMapNode
        shadows = tileMap.childNode(withName: SceneNode.shadows) as? SKTileMapNode
        grass = tileMap.childNode(withName: SceneNode.grass) as? SKTileMapNode
        items = tileMap.childNode(withName: SceneNode.items) as? SKTileMapNode
        sfx = tileMap.childNode(withName: SceneNode.sfx) as? SKTileMapNode
        player = tileMap?.childNode(withName: SceneNode.player) as? SKSpriteNode
        player.run(Character.wizard.animFrames(.l), type: "idle")
        playerSquare = player.childNode(withName: SceneNode.square) as? SKShapeNode
        playerSquare.isHidden = true
    }
}
