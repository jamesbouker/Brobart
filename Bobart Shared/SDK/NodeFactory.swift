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
    func label(text: String, color: UIColor, node: SKNode, z: CGFloat) -> SKLabelNode {
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
}
