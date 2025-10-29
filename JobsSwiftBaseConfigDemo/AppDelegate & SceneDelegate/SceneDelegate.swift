//
//  SceneDelegate.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/4.
//

import UIKit
import LiveChat

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        LiveChat.windowScene = (scene as? UIWindowScene)
        self.window = UIWindow(windowScene: windowScene)
            .byRootViewController(RootListVC().jobsNav.jobsNavContainer)
            .byMakeKeyAndVisible()
    }
}
