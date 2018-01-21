//
//  ActionFactory.swift
//  Bobart
//
//  Created by james bouker on 1/21/18.
//  Copyright © 2018 JimmyBouker. All rights reserved.
//

import SpriteKit

extension SKAction {
    class func fadeIn(_ time: TimeInterval) -> SKAction {
        return .fadeIn(withDuration: time)
    }

    class func fadeOut(_ time: TimeInterval) -> SKAction {
        return .fadeOut(withDuration: time)
    }

    class func wait(_ time: TimeInterval) -> SKAction {
        return .wait(forDuration: time)
    }

    class func blink() -> SKAction {
        let time = frameTime / 6.0
        let fade = SKAction.sequence([.fadeOut(time), .fadeIn(time)])
        return .sequence([fade, fade, fade, fade, .fadeOut(time)])
    }
}

extension GameScene {
    func showText(node: SKNode, text: String, color: UIColor = #colorLiteral(red: 1, green: 0.2876047492, blue: 0.2655626833, alpha: 1)) -> SKAction {
        let action = SKAction.run {
            self.label(text: text, color: color, node: node, z: 101)
            let textNode2 = self.label(text: text, color: .black, node: node, z: 100)
            textNode2.position.x += 2.0
            textNode2.position.y -= 2
        }
        action.duration = frameTime * 1.75
        return action
    }

    func images(rangedItem meta: RangedItemMeta, direction: Direction) -> [SKTexture] {
        var images = [SKTexture]()
        for i in 1 ... meta.frames {
            let file = meta.asset + "_\(i)" + (meta.directional ? "_\(direction.rawValue)" : "")
            let image = SKTexture.pixelatedImage(file: file)
            images.append(image)
        }
        return images
    }

    func fire(item: String,
              to: MapLocation,
              from: MapLocation,
              node: SKSpriteNode) -> SKAction {

        let delta = (to - from).normalized
        let direction = Direction(facing: delta)
        let meta = RangedItemMeta.rangedItemMeta(id: item)
        let duration = Double((to - from).length) * frameTime / 1.5
        let toPoint = to.point * tileLength
        var start = from.point * tileLength
        start += (delta.point * tileLength / 2.0)

        let action = SKAction.run {
            let images = self.images(rangedItem: meta, direction: direction)
            let projectile = SKSpriteNode(texture: images.first!, color: .white, size: tileSize)
            projectile.anchorPoint = .zero
            projectile.position = start
            self.tileMap.addChild(projectile)

            node.run(self.bump(direction: direction))
            projectile.runs([.move(to: toPoint, duration: duration), .removeFromParent()])

            if meta.frames > 1 {
                projectile.run(.repeatForever(.animate(with: images, timePerFrame: frameTime / Double(meta.frames))))
            }
        }
        return .group([action, .wait(duration)])
    }

    func bump(direction: Direction) -> SKAction {
        let offset = direction.loc.point
        let moveBy = CGVector(dx: offset.x * tileLength / 3, dy: offset.y * tileLength / 3)
        let bump = SKAction.move(by: moveBy, duration: frameTime / 2)
        return .sequence([bump, bump.reversed()])
    }

    func walk(loc: MapLocation) -> SKAction {
        let x = CGFloat(loc.x) * tileLength
        let y = CGFloat(loc.y) * tileLength
        let pt = CGPoint(x: x, y: y)
        return .move(to: pt, duration: frameTime)
    }

    func idle(character: String, facing: Direction?) -> SKAction {
        let c = Character(rawValue: character)!
        return c.animFrames(facing)
    }
}
