//
//  AppDelegate.swift
//  AssignmentVersionOne
//
//  Created by 于昕卓 on 30/8/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var persistantContainer: NSPersistentContainer?
    var databaseController: DatabaseProtocol?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        let splitView = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitView.viewControllers.first as! UINavigationController
        let mapView = splitView.viewControllers.last as! MapViewController
        let locationView = navigationController.viewControllers.first as! LocationTableViewController
        
        locationView.mapViewController = mapView
        databaseController = CoreDataControllerController()
//        persistantContainer = NSPersistentContainer(name: "ImageModel")
//        persistantContainer?.loadPersistentStores() { (description, error) in
//            if let error = error {
//                fatalError("Failed to load Core Data stack: \(error)")
//            }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

