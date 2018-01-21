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

        if to.blocked {
            let text = showText(node: node, text: "block", color: .white)
            node.runs([.wait(forDuration: startDelay), text])
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
                let text = showText(node: self.player, text: "\(to.meta.attack)")

                if (to.loc - player.loc).length > 1 {
                    let shoot = fire(item: to.meta.rangedItem!, to: player.loc, from: to.loc, node: node)
                    move = .sequence([shoot, text])
                } else {
                    move = .group([bump(direction: direction), text])
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
