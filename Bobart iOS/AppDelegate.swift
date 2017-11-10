//
//  AppDelegate.swift
//  Bobart iOS
//
//  Created by james bouker on 11/7/17.
//  Copyright © 2017 JimmyBouker. All rights reserved.
//

import UIKit
import ReSwift

var store: Store<GameState> = Store(reducer: gameReducer, state: nil)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}
