//
//  Actions.swift
//  Bobart
//
//  Created by james bouker on 11/7/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

enum PlayerAction: UInt8, Codable, Action {
    case pressed
    case moveRight
    case moveLeft
    case moveUp
    case moveDown
}
