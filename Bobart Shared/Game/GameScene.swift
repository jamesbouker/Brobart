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
    private var actions = [PlayerAction]()
    private var isExecuting = false
    var playerAction: PlayerAction? {
        didSet {
            if let action = playerAction {
                actions.append(action)
                executeFirstAction()
            }
        }
    }
    private var state: GameState!

    #if os(watchOS)
        override func sceneDidLoad() { setupView() }
    #else
        override func didMove(to _: SKView) { setupView() }
    #endif
    func setupView() {
        grabOutlets()
        store.subscribe(self)
    }

    func grabOutlets() {
        tileMap = childNode(withName: SceneNode.base) as? SKTileMapNode
        shadows = tileMap.childNode(withName: SceneNode.shadows) as? SKTileMapNode
        grass = tileMap.childNode(withName: SceneNode.grass) as? SKTileMapNode
        items = tileMap.childNode(withName: SceneNode.items) as? SKTileMapNode
        sfx = tileMap.childNode(withName: SceneNode.sfx) as? SKTileMapNode
        player = tileMap?.childNode(withName: SceneNode.player) as? SKSpriteNode
        playerSquare = player.childNode(withName: SceneNode.square) as? SKShapeNode
        playerSquare.isHidden = true
    }

    func executeFirstAction() {
        guard !isExecuting, actions.count > 0 else {
            return
        }

        let action = actions.removeFirst()
        store.dispatch(action)
    }
}

extension GameScene: StoreSubscriber {
    func newState(state: GameState) {
        if self.state == nil {
            self.state = state
            layout(state: state)
            isExecuting = false
            executeFirstAction()
        } else {
            isExecuting = true
//            runs([.wait(forDuration: 1.0), .run {
                self.state = state
                self.layout(state: state)
                self.isExecuting = false
                self.executeFirstAction()
//            }])
            // Run diff states, then run SKAction
            // On SKAction run complete, set isExecuting = false
            // Then call executeFirstAction()
        }
    }
}
