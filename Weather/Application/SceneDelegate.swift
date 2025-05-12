//
//  SceneDelegate.swift
//  Weather
//
//  Created by Yury Lebedev on 12.05.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private let weatherAPIKey = "fa8b3df74d4042b9aa7135114252304" // В идеале получать его с бека, в plist тоже такое себе его хранить
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let keychainService = KeychainService()
        saveAPIKeyIfNeeded(keychainService: keychainService)
        
        let locationService = LocationService()
        let networkService = NetworkService(keychainService: keychainService)
        let viewController = ViewController()
        let presenter = WeatherPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        let interactor      = WeatherInteractor(locationService: locationService,
                                                networkService: networkService)
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        let navigationController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func saveAPIKeyIfNeeded(keychainService: KeychainServiceProtocol) {
        if keychainService.getAPIKey() == nil {
            if keychainService.saveAPIKey(weatherAPIKey) {
                print("SceneDelegate: Successfully saved API Key to Keychain.")
            } else {
                print("SceneDelegate: Failed to save API Key to Keychain!")
            }
        } else {
            print("SceneDelegate: API Key already exists in Keychain.")
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
