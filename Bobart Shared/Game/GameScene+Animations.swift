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

        let animDuration = frameTime
        let action = SKAction.run {

            // Animate the player!
            self.playerAnim(to: to)

            // Animate the monsters!
            for (i, monster) in self.monsters.enumerated() {
                let state = to.monsterStates[i]
                self.monsterAnim(to: state, for: monster)
            }
        }

        runs([action, .wait(forDuration: animDuration), .run {
            done()
        }])
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
    func monsterAnim(to: MonsterState, for node: SKSpriteNode) {
        let move = walk(loc: to.loc)
        node.run(move)
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
