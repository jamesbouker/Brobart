//
//  GameSceneModel.swift
//  Bobart
//
//  Created by james bouker on 11/10/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import ReSwift
import SpriteKit

typealias Completion = () -> Void
typealias LayoutFunc = (GameState) -> Void
typealias AnimateFunc = (GameState, @escaping Completion) -> Void

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
    private var animFunc: AnimateFunc
    init(layout: @escaping LayoutFunc, anim: @escaping AnimateFunc) {
        layoutFunc = layout
        animFunc = anim
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
        return state.playerState.loc == state.mapState.stairLoc && state.mapState.switchHit
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
            layoutFunc(state)
            finishStateTransition(to: state)
        } else {
            isExecuting = true
            self.layoutFunc(state)

            animFunc(state, {
                self.finishStateTransition(to: state)
            })
        }
    }
}
