//
//  InterfaceController.swift
//  Rune watchOS Extension
//
//  Created by james bouker on 9/25/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import WatchKit
import Foundation

var sharedController: InterfaceController!
class InterfaceController: WKInterfaceController {

    // Shared
    var scene: GameScene!

    func setHp(current _: Int, max _: Int) {
        //        self.hp.text = "\(current) / \(max)"
    }

    func setFood(_: Int) {
        //        self.food.text = "\(food)"
    }

    @IBOutlet var skInterface: WKInterfaceSKScene!
    var touchDownTime: Date?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        sharedController = self

        scene = GameScene(fileNamed: "GameScene")!
        scene.scaleMode = .aspectFill
        skInterface.preferredFramesPerSecond = 60
        skInterface.presentScene(scene)
    }

    var initialLocation: CGPoint?
    @IBAction func screenLongPressed(gesture: WKLongPressGestureRecognizer) {
        if gesture.state == .began {
            initialLocation = gesture.locationInObject()
        }
        if gesture.state == .ended, let loc = initialLocation {
            let delta = gesture.locationInObject() - loc
            if delta.lengthSquared() < 100 {
                scene.viewModel.playerAction = .pressed
            }
        }
    }

    @IBAction func screenPanned(_ gesture: WKPanGestureRecognizer) {
        if touchDownTime == nil {
            print("Gesture.state: \(gesture.state)")
            touchDownTime = Date()
            return
        }

        if gesture.state != .ended {
            return
        }

        guard let touchDown = touchDownTime else { return }
        let time = Date().timeIntervalSince(touchDown)
        let delta: CGFloat = tileLength / 2
        let deltaX = gesture.translationInObject().x
        let deltaY = gesture.translationInObject().y

        let kill = {
            self.touchDownTime = nil
        }

        guard abs(deltaX) > delta || abs(deltaY) > delta else {
            if time > 0.3 {
                kill()
            }
            return
        }

        if abs(deltaX) > abs(deltaY) {
            if deltaX > delta {
                kill()
                scene.viewModel.playerAction = .moveRight
            } else if deltaX < -delta {
                kill()
                scene.viewModel.playerAction = .moveLeft
            }
        } else {
            if deltaY > delta {
                kill()
                scene.viewModel.playerAction = .moveDown
            } else if deltaY < -delta {
                kill()
                scene.viewModel.playerAction = .moveUp
            }
        }
    }
}
