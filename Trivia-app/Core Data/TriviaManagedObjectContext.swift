//
//  TriviaManagedObjectContext.swift
//  Trivia-app
//
//  Created by Pradnya Achari on 21/07/20.
//  Copyright © 2020 Pradnya Achari. All rights reserved.
//

import Foundation
import CoreData

class TriviaManagedObjectContext: NSManagedObjectContext {
        
    // MARK: Factory Methods
    class func managedObjectContext(isForBackgroundThread: Bool = false, mergeDataChangesFromOtherContexts: Bool = false) -> TriviaManagedObjectContext {
        let concurrencyType: NSManagedObjectContextConcurrencyType = isForBackgroundThread ? .privateQueueConcurrencyType : .mainQueueConcurrencyType
        let managedObjectContext = TriviaManagedObjectContext(concurrencyType: concurrencyType)
        managedObjectContext.persistentStoreCoordinator = sharedPersistentStoreCoordinator
        
        if mergeDataChangesFromOtherContexts {
            NotificationCenter.default.addObserver(managedObjectContext, selector: #selector(mergeDataChanges(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
        }
        return managedObjectContext
    }
    
    public static func appDidLaunch() {
        let _ = sharedPersistentStoreCoordinator
    }
    
    // WARNING: Multiple copies of this sharedPersistentStoreCoordinator get created if the managedObjectContext is called simultaneously from different parallel threads. As Swift documentation says "If a property marked with the lazy modifier is accessed by multiple threads simultaneously and the property has not yet been initialized, there is no guarantee that the property will be initialized only once." This causes crashes, as only the last copy is referenced and all earlier ones are garbage collected. Synchronizing the calls is not a solution, as that will only serialize the creation of the many sharedPersistentStoreCoordinator objects. One solution (implemented here), is to make the static variable non-lazy by using it early in the app lifecycle - when the app launches. The appDidLaunch function achieves that.
    private static var sharedPersistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let aPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: TriviaManagedObjectContext.sharedManagedObjectModel)
        let dataMigrationOptions = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]   // Enable automatic migration of the database to a new version.
        try! aPersistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: SQLiteFileURL, options: dataMigrationOptions)
        return aPersistentStoreCoordinator
    }()
    
    private static var sharedManagedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "DataModel", withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    private static var SQLiteFileURL: URL = {
        // Store the SQLite file in the Application Support directory as recommended by Apple in the File System Programming Guide.
        let applicationSupportDirectoryPaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let SQLiteDirectory = applicationSupportDirectoryPaths.first! + "/SQLite"
        if !FileManager.default.fileExists(atPath: SQLiteDirectory) {
            try! FileManager.default.createDirectory(atPath: SQLiteDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        let SQLiteFileName:String = "SQLiteDatabase"
        return URL(fileURLWithPath: SQLiteDirectory, isDirectory: true).appendingPathComponent(SQLiteFileName).appendingPathExtension("sqlite")
    }()
    
    // MARK: Merge Changes from Other Contexts
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(concurrencyType ct: NSManagedObjectContextConcurrencyType) {
        super.init(concurrencyType: ct)
    }
    
    // This method is most often used to merge changes from a background operation (fetch from server) done on a background queue to a managed object context in the main queue. This method is the selector for the NSManagedObjectContextDidSave notification. It is almost always called on a background queue (thread) different from main queue.
    @objc func mergeDataChanges(_ notificationsChangeNotification: Foundation.Notification) {
        // Filter out notifications from Google Analytics and other frameworks that save to Core Data
        let notifier = notificationsChangeNotification.object as! NSManagedObjectContext
        if notifier.persistentStoreCoordinator !== TriviaManagedObjectContext.sharedPersistentStoreCoordinator { return }
        
        if notifier === self { return } // Prevent an infinite loop from changes triggered from this managed object context
        
        // The notification may be fired on different thread/queue. Use perform to use the queue of this managed object context to merge changes. Use perform instead of performAndWait. perform is a asynchronous operation whereas performAndWait is a synchronous one. Using perform may delay the merge operation, but it may also give the main queue the chance to complete a UI operation that it was processing. Using perform sometimes causes crashes as the async thread executes at a later time.
        // Changed objects in the notification will be safely handled by mergeChanges even if they come from a different thread. But our program itself should not use those managed objects directly.
        performAndWait { [weak self] in
            if let aSelf = self { aSelf.mergeChanges(fromContextDidSave: notificationsChangeNotification) }
        }
    }
}
