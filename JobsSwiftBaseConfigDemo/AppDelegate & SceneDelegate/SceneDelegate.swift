//
//  SceneDelegate.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/4.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
//        let rootVC = ViewController()
        let rootVC = TextFieldVC()
        let nav = UINavigationController(rootViewController: rootVC)
        window.rootViewController = nav
        self.window = window
        window.makeKeyAndVisible()
    }
}
