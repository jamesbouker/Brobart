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
