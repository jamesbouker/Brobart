//
//  GameViewController.swift
//  1 Bit Rogue
//
//  Created by james bouker on 7/29/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import UIKit
import ReSwift
import SpriteKit

var sharedController: GameViewController!
class GameViewController: UIViewController {

    // Shared
    var scene: GameScene!
    @IBOutlet weak var hp: UILabel!
    @IBOutlet weak var food: UILabel!
    @IBOutlet weak var floor: UILabel!

    func setHp(current: Int, max: Int) {
        hp.text = "\(current) / \(max)"
    }

    func setFood(_ food: Int) {
        self.food.text = "\(food)"
    }

    func setFloor(_ floor: Int) {
        self.floor.text = "\(floor)"
    }

    var touchDownLocation: CGPoint?
    var touchDownTime: Date?

    @IBOutlet weak var heartIcon: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedController = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = self.view as? SKView else { return }
        let scene = GameScene(fileNamed: "GameScene")!

        scene.scaleMode = .aspectFill
        view.preferredFramesPerSecond = 60
        view.ignoresSiblingOrder = true
        view.presentScene(scene)

        self.scene = view.scene as? GameScene
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let location = touches.first?.location(in: nil) else { return }
        touchDownLocation = location
        touchDownTime = Date()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touchDown = touchDownTime else { return }
        guard let to = touches.first?.location(in: nil) else { return }
        guard let from = touchDownLocation else { return }
        let time = Date().timeIntervalSince(touchDown)
        let delta: CGFloat = tileLength / 2
        let deltaX = (to - from).x
        let deltaY = (to - from).y

        let kill: () -> Void = {
            self.touchDownLocation = nil
            self.touchDownTime = nil
        }

        guard abs(deltaX) > delta || abs(deltaY) > delta else {
            if time > 0.3 {
                kill()
                scene.viewModel.playerAction = .pressed
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
