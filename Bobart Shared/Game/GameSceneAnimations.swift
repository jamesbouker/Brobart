//
//  GameSceneAnimations.swift
//  Bobart
//
//  Created by james bouker on 11/11/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import SpriteKit

extension GameScene {
    func animate(to: GameState, done: @escaping () -> ()) {

        let animDuration = frameTime
        let action = SKAction.run {
            let playerWalk = self.playerAnim(to: to)
            self.player.run(playerWalk)
        }

        runs([action, .wait(forDuration: animDuration), .run {
            done()
        }])
    }

    func playerAnim(to: GameState) -> SKAction {
        let loc = to.playerState.loc
        let x = CGFloat(loc.x) * tileSize
        let y = CGFloat(loc.y) * tileSize
        let pt = CGPoint(x: x, y: y)
        return SKAction.move(to: pt, duration: frameTime)
    }
}
