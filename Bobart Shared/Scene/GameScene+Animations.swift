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
    func animate(to: GameState, done: @escaping () -> Void) {

        var animDuration = frameTime
        let action = SKAction.run {

            // Animate the player!
            self.playerAnim(to: to)

            // Animate the monsters!
            for (i, monster) in self.monsters.enumerated() {
                let state = to.monsterStates[i]
                let duration = self.monsterAnim(to: state, for: monster)
                if animDuration < duration {
                    animDuration = duration
                }
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
    func bump(direction: Direction) -> SKAction {
        let offset = direction.loc.point
        let moveBy = CGVector(dx: offset.x * tileSize / 3, dy: offset.y * tileSize / 3)
        let bump = SKAction.move(by: moveBy, duration: frameTime / 2)
        return .sequence([bump, bump.reversed()])
    }

    func walk(loc: MapLocation) -> SKAction {
        let x = CGFloat(loc.x) * tileSize
        let y = CGFloat(loc.y) * tileSize
        let pt = CGPoint(x: x, y: y)
        return .move(to: pt, duration: frameTime)
    }
}

// MARK: - Monster Animations
private extension GameScene {
    func monsterAnim(to: MonsterState, for node: SKSpriteNode) -> TimeInterval {
        var delay: TimeInterval = 0.0

        guard let previous = self.viewModel.state?.monsterStates, previous.count > to.index else {
            node.run(walk(loc: to.loc))
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
                let c = Character(rawValue: to.asset)!
                let direction = to.meta.isDirectional ? to.facing : nil
                let anim = c.animFrames(direction)
                node.removeAction(forKey: ActionType.idle)
                node.run(anim, type: ActionType.idle)
            }
        }

        // Add getting attacked (Player attack animation time) to the delay
        if from.hp != to.hp {
            // Could eventually change based on player attack type
            // Basic bump attack for now is frameTime
            delay = frameTime
        }

        // Alive - animate the monster
        if to.hp > 0 {
            let move: SKAction
            if let direction = to.hitDirection {
                // Add attacking the player animation time to the delay
                // Could eventually change based on enemy ranged attack time
                // Basic bump attack for now is frameTime
                delay += frameTime
                move = bump(direction: direction)
            } else {
                move = walk(loc: to.loc)
            }
            node.runs([.wait(forDuration: delay), .run(custom), move])
            return frameTime + delay
        }

        // If dying, blink the anim, fade it out, and remove it from the scene
        let fadeOut = SKAction.fadeOut(withDuration: frameTime / 6.0)
        let fadeIn = SKAction.fadeIn(withDuration: frameTime / 6.0)
        let fade = SKAction.sequence([fadeOut, fadeIn])
        let death = SKAction.sequence([fade, fade, fade, fade, fadeOut])
        node.runs([.wait(forDuration: delay), death, .run {
            node.isHidden = true
            node.removeAllActions()
            node.removeFromParent()
        }])
        return 1.5 * frameTime + delay
    }
}

// MARK: - Player Animations
private extension GameScene {
    func playerAnim(to: GameState) {
        var move = walk(loc: to.playerState.loc)

        // Animate right away if changing levels
        if to.mapState.level != viewModel.state?.mapState.level {
            move.duration = 0
        }

        // If player direction changed, update idle animation
        let custom = {
            if to.playerState.facing != self.viewModel.state?.playerState.facing {
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
    }
}
