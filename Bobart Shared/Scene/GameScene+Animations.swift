//
//  GameSceneAnimations.swift
//  Bobart
//
//  Created by james bouker on 11/11/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import SpriteKit

// MARK: - Main
extension GameScene {
    func animate(to: GameState, from: GameState, done: @escaping () -> Void) {

        var animDuration = 0.0
        let action = SKAction.run {

            // Animate the player!
            let playerDuration = self.playerAnim(to: to)

            // Find monsters getting hurt
            var hurtMonsters = [MonsterState: MonsterState]()
            if to.mapState.level == from.mapState.level {
                let mon = to.monsterStates.filter { $0.hp != from.monsterStates[$0.index].hp }
                hurtMonsters = mon.toDictionary { $0 }
            }

            // Animate monsters getting hurt all at once
            var monsterHurtAnim = 0.0
            for hurt in hurtMonsters.values where hurt.hitDirection == nil {
                monsterHurtAnim = max(monsterHurtAnim,
                                      self.monsterAnim(hurt, to.playerState, self.monsters[hurt.index], animDuration))
            }
            animDuration += monsterHurtAnim

            // Animate monsters NOT (getting hurt || attacking player)
            var monsterWalkAnim = 0.0
            let walking = to.monsterStates.filter { !hurtMonsters.hasKey($0) && $0.hitDirection == nil }
            for w in walking {
                monsterWalkAnim = max(monsterWalkAnim,
                                      self.monsterAnim(w, to.playerState, self.monsters[w.index], monsterHurtAnim))
            }
            animDuration += max(playerDuration, monsterWalkAnim)

            // Animate monsters hurting player!
            let monstersAttacking = to.monsterStates.filter { $0.hitDirection != nil }
            for attacker in monstersAttacking {
                animDuration += self.monsterAnim(attacker, to.playerState, self.monsters[attacker.index], animDuration)
            }

            self.runs([.wait(forDuration: animDuration), .run {
                done()
            }])
        }
        run(action)
    }
}

// MARK: Shared Animations
private extension GameScene {
    func showText(node: SKNode, text: String) -> SKAction {
        let action = SKAction.run {
            self.label(text: text, color: #colorLiteral(red: 1, green: 0.2876047492, blue: 0.2655626833, alpha: 1), node: node, z: 101)
            let textNode2 = self.label(text: text, color: .black, node: node, z: 100)
            textNode2.position.x += 2.0
            textNode2.position.y -= 2
        }
        action.duration = frameTime * 2.0
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
        action.duration = duration
        return action
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

// MARK: - Monster Animations
private extension GameScene {

    @discardableResult
    func monsterAnim(_ to: MonsterState,
                     _ player: PlayerState,
                     _ node: SKSpriteNode,
                     _ startDelay: TimeInterval) -> TimeInterval {
        guard let previous = self.viewModel.state?.monsterStates, previous.count > to.index else {
            assert(false, "This should never happen!")
            node.runs([.wait(forDuration: startDelay), walk(loc: to.loc)])
            return frameTime
        }
        let from = previous[to.index]
        if from.hp <= 0 && to.hp <= 0 {
            node.isHidden = true
            return 0
        }

        // If direction changed, update idle animation
        let custom = {
            if to.facing != from.facing {
                let direction = to.meta.isDirectional ? to.facing : nil
                let anim = self.idle(character: to.asset, facing: direction)
                node.removeAction(forKey: ActionType.idle)
                node.run(anim, type: ActionType.idle)
            }
        }

        // If hurt show text
        if to.hp < from.hp {
            let text = showText(node: node, text: "\(from.hp - to.hp)")
            node.runs([.wait(forDuration: startDelay), text])
        }

        // Alive - animate the monster
        if to.hp > 0 {
            let move: SKAction
            if let direction = to.hitDirection {
                if (to.loc - player.loc).length > 1 {
                    move = fire(item: to.meta.rangedItem!, to: player.loc, from: to.loc, node: node)
                } else {
                    move = bump(direction: direction)
                }
            } else {
                move = walk(loc: to.loc)
            }

            node.runs([.wait(forDuration: startDelay), .run(custom), move])
            return move.duration
        }

        // If dying, blink the anim, fade it out, and remove it from the scene
        node.runs([.wait(forDuration: startDelay), .blink(), .run {
            node.isHidden = true
            node.removeAllActions()
            node.removeFromParent()
        }])
        return 1.5 * frameTime
    }
}

// MARK: - Player Animations
private extension GameScene {
    func playerAnim(to: GameState) -> TimeInterval {
        var move = walk(loc: to.playerState.loc)

        // Animate right away if changing levels
        if to.mapState.level != viewModel.state?.mapState.level {
            move.duration = 0
        }

        // If player direction changed, update idle animation
        let custom = {
            if to.playerState.hp <= 0 {
                self.player.removeAllActions()
                self.player.texture = SKTexture.pixelatedImage(file: "rip")
            } else if to.playerState.facing != self.viewModel.state?.playerState.facing {
                let c = Character.wizard
                let anim = c.animFrames(to.playerState.facing)
                self.player.removeAction(forKey: ActionType.idle)
                self.player.run(anim, type: ActionType.idle)
            }
        }

        // Walk or bump!?
        if let direction = to.playerState.hitDirection {
            move = bump(direction: direction)
        }

        // Idle anim + move
        let anim = SKAction.sequence([.run(custom), move])

        // Run the animation on the player
        player.run(anim)

        return frameTime
    }
}
