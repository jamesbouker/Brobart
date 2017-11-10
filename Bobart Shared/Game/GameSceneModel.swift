//
//  GameSceneModel.swift
//  Bobart
//
//  Created by james bouker on 11/10/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift

typealias LayoutFunc = (GameState) -> Void

class GameSceneModel {
    private var state: GameState!

    private var actions = [PlayerAction]()
    private var isExecuting = false
    var playerAction: PlayerAction? {
        didSet {
            if let action = playerAction {
                actions.append(action)
                executeFirstAction()
            }
        }
    }

    private var layoutFunc: LayoutFunc
    init(layout: @escaping LayoutFunc) {
        layoutFunc = layout
        store.subscribe(self)
    }

    func executeFirstAction() {
        guard !isExecuting, actions.count > 0 else {
            return
        }

        let action = actions.removeFirst()
        store.dispatch(action)
    }
}

extension GameSceneModel: StoreSubscriber {
    private func onStairs() -> Bool {
        return state.playerState.loc == state.mapState.stairLoc && state.mapState.switchToggled
    }

    private func finishStateTransition() {
        isExecuting = false
        if onStairs() {
            actions.removeAll()
            playerAction = .loadNextLevel
        } else {
            self.executeFirstAction()
        }
    }

    func newState(state: GameState) {
        if self.state == nil {
            self.state = state
            self.layoutFunc(state)
            finishStateTransition()
        } else {
            isExecuting = true
            //            runs([.wait(forDuration: 1.0), .run {
            self.state = state
            self.layoutFunc(state)
            self.finishStateTransition()
            //            }])
            // Run diff states, then run SKAction
            // On SKAction run complete, set isExecuting = false
            // Then call executeFirstAction()
        }
    }
}
