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
    var state: GameState?

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
    }

    func subscribe() {
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
        guard let state = state else { return false }
        return state.playerState.loc == state.mapState.stairLoc && state.mapState.switchToggled
    }

    private func finishStateTransition(to: GameState) {
        state = to
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
            self.layoutFunc(state)
            finishStateTransition(to: state)
        } else {
            isExecuting = true
            //            runs([.wait(forDuration: 1.0), .run {
            self.layoutFunc(state)
            self.finishStateTransition(to: state)
            //            }])
            // Run diff states, then run SKAction
            // On SKAction run complete, set isExecuting = false
            // Then call executeFirstAction()
        }
    }
}
