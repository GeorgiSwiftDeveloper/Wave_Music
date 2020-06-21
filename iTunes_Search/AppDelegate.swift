//
//  AppDelegate.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 3/31/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
              UserDefaults.standard.removeObject(forKey: "checkIfMyLibraryViewControllerRowIsSelected")
              UserDefaults.standard.removeObject(forKey: "saveTopHitsSelectedIndex")
              UserDefaults.standard.removeObject(forKey: "saveLibrarySelectedIndex")
              UserDefaults.standard.removeObject(forKey: "saveGenreSelectedIndex")
              UserDefaults.standard.removeObject(forKey: "saveRecentlyPlayedSelectedIndex")
              UserDefaults.standard.removeObject(forKey: "checkIfSearchRowIsSelected")
              UserDefaults.standard.removeObject(forKey: "checkGenreRowIsSelected")
              UserDefaults.standard.removeObject(forKey: "selectedSearch")
              UserDefaults.standard.removeObject(forKey: "pause")

        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "SelectedObjectModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
}
