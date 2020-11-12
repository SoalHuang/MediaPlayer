//
//  AppDelegate.swift
//  Demo
//
//  Created by SoalHunag on 2019/12/27.
//  Copyright © 2019 SoalHunag. All rights reserved.
//

import UIKit
import VideoCache

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        
        window?.makeKeyAndVisible()
        
        setupVideoCache()
        
        return true
    }
}

extension AppDelegate {
    
    private static let VideoCacheVersionKey = "VideoCacheVersionKey"
    
    private static let CurrentVideoCacheVersion: Int = 1
    
    func setupVideoCache() {
        
        VideoCacheManager.logLevel = .info
        
        VideoCacheManager.default.isAutoCheckUsage = true
        VideoCacheManager.default.capacityLimit = Int64(200).MB
        
        let savedVersion = UserDefaults.standard.integer(forKey: AppDelegate.VideoCacheVersionKey)
        
        guard savedVersion < AppDelegate.CurrentVideoCacheVersion else { return }
        
        do {
            try VideoCacheManager.default.cleanAll()
            UserDefaults.standard.set(AppDelegate.CurrentVideoCacheVersion, forKey: AppDelegate.VideoCacheVersionKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("Video Cache clean failure: \(error)")
        }
    }
}
