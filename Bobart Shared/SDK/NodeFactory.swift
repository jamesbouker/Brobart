//
//  NodeFactory.swift
//  Bobart
//
//  Created by james bouker on 1/21/18.
//  Copyright © 2018 JimmyBouker. All rights reserved.
//

import SpriteKit

extension GameScene {

    @discardableResult
    func labelNode(text: String, color: UIColor, node: SKNode, z: CGFloat) -> SKLabelNode {
        let textNode = SKLabelNode(text: text)
        textNode.fontColor = color
        textNode.fontSize = tileLength / 1.5
        textNode.fontName = "pixelated"
        textNode.position = CGPoint(x: node.position.x + tileLength / 2.0, y: node.position.y + tileLength * 0.75)
        textNode.zPosition = z
        textNode.alpha = 0
        tileMap.addChild(textNode)

        let move = SKAction.move(by: CGVector(dx: 0, dy: tileLength / 2.0), duration: frameTime * 0.75)
        move.timingMode = .easeInEaseOut

        let time = frameTime / 4.0
        let group = SKAction.group([.fadeIn(time), move])
        textNode.runs([group, .wait(1.25 * frameTime), .fadeOut(time), .removeFromParent()])

        return textNode
    }

    func foodNode(loc: MapLocation) {
        let texture = SKTexture.pixelatedImage(file: "food-1")
        let node = SKSpriteNode(texture: texture, color: .white, size: tileSize)
        node.name = "food"
        node.anchorPoint = .zero
        node.position = loc.point * tileLength
        node.zPosition = ZPositions.droppedItems
        tileMap.addChild(node)
        food[loc] = node
    }
}
