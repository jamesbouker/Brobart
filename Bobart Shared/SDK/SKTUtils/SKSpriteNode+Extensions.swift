//
//  NodeExtensions.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/31/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import SpriteKit

extension SKSpriteNode {
    func runs(_ actions: [SKAction], type: String) {
        run(.sequence(actions), withKey: type)
    }

    func run(_ action: SKAction, type: String) {
        run(action, withKey: type)
    }
}
