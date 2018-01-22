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
typealias LayoutFunc = (GameState, GameState?) -> Void
typealias AnimateFunc = (GameState, GameState, @escaping Completion) -> Void

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

    private func anyoneAttacked() -> Bool {
        guard let state = state else { return false }
        return state.playerState.hitDirection != nil || state.monsterStates.contains { $0.hitDirection != nil }
    }

    private func finishStateTransition(to: GameState) {
        state = to
        isExecuting = false
        if onStairs() {
            actions.removeAll()
            playerAction = .loadNextLevel
        } else if anyoneAttacked() {
            actions.removeAll()
        } else {
            self.executeFirstAction()
        }
    }

    func newState(state: GameState) {
        if let from = self.state {
            isExecuting = true
            self.layoutFunc(state, self.state)

            animFunc(state, from, {
                self.finishStateTransition(to: state)
            })
        } else {
            layoutFunc(state, self.state)
            finishStateTransition(to: state)
        }
    }
}
