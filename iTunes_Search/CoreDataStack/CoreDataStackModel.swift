//
//  CoreDataStackModel.swift
//  iTunes_Search
//
//  Created by Georgi Malkhasyan on 4/29/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStackModel: NSObject {
    static var sharedInstance = CoreDataStackModel()
        var entityName = ""
        func applicationWillTerminate(_ application: UIApplication) {
            // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
            // Saves changes in the application's managed object context before the application terminates.
            self.saveContext()
        }
        
//        class NSCustomPersistentContainer: NSPersistentContainer {
//
//            override open class func defaultDirectoryURL() -> URL {
//                var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.healthwidget.widget")
//                storeURL = storeURL?.appendingPathComponent("HealthTodayApp.sqlite")
//                return storeURL!
//            }
//
//        }
        
        // MARK: - Core Data stack
        
        lazy var persistentContainer: NSPersistentContainer = {
     
            let container = NSPersistentContainer(name: "MyLibraryMusicData")
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
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
}
