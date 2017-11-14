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
            self.playerAnim(to: to)
        }
        runs([action, .wait(forDuration: animDuration), .run {
            done()
        }])
    }
}

// MARK: Shared Animations
private extension GameScene {
    func bump(_: SKNode, direction: Direction) -> SKAction {
        let offset = direction.loc.point
        let moveBy = CGVector(dx: offset.x * tileSize / 3, dy: offset.y * tileSize / 3)
        let bump = SKAction.move(by: moveBy, duration: frameTime / 2)
        return .sequence([bump, bump.reversed()])
    }
}

// MARK: - Player Animations
private extension GameScene {
    func playerAnim(to: GameState) {
        let loc = to.playerState.loc
        let x = CGFloat(loc.x) * tileSize
        let y = CGFloat(loc.y) * tileSize
        let pt = CGPoint(x: x, y: y)

        // How long to animate?
        var walkDuration = frameTime
        if to.mapState.level != viewModel.state?.mapState.level {
            walkDuration = 0 // 0 if changing levels
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
        var move = SKAction.move(to: pt, duration: walkDuration)
        if let direction = to.playerState.hitDirection {
            move = bump(player, direction: direction)
        }

        // Idle anim + move
        let anim = SKAction.sequence([.run(custom), move])

        // Run the animation on the player
        player.run(anim)
    }
}
