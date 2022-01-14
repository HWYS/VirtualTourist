//
//  SceneDelegate.swift
//  Virtual Tourist
//
//  Created by Htet Wai Yan Swe on 1/7/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var dataController = DataController(modelName: "VirtualTourist")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let mapViewController = navigationController.topViewController as! MapViewController
        mapViewController.dataController = dataController
    }

   
    func sceneDidEnterBackground(_ scene: UIScene) {
        saveViewContext()
    }

    private func saveViewContext() {
        try? dataController.viewContext.save()
    }

}

