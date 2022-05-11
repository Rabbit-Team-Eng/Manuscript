//
//  AppDelegate.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/9/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        printOutCoreDataDatabaseLocation()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    private func printOutCoreDataDatabaseLocation() {
        #if targetEnvironment(simulator)
        print("\n\n\n\n=================================CORE DATA LOCAL SQLite FILE LOCATION=================================")
        print("In order to open the local SQLite file use the following command in terminal. Make sure you have appropriate soft installed.")
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let terminalComand = "open /Users/\(paths[0].split(separator: "/")[1])/Library/Developer/CoreSimulator/Devices/\(paths[0].split(separator: "/")[6])/data/Containers/Data/Application/\(paths[0].split(separator: "/")[11])/Library/Application\\ Support/TaskDB.sqlite "
        print(terminalComand)
        print("===================================================================================================\n")
        #endif
    }


}

