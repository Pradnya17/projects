//
//  NSManagedObject+Extension.swift
//  Trivia-app
//
//  Created by Pradnya Achari on 21/07/20.
//  Copyright © 2020 Pradnya Achari. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    // MARK: Factory Methods
    class func managedObject<T>(_ managedObjectContext: NSManagedObjectContext) -> T {
        let className = NSStringFromClass(self)
        return NSEntityDescription.insertNewObject(forEntityName: className, into: managedObjectContext) as! T
    }
    
    // MARK: Purge
    class func purge(in managedObjectContext: NSManagedObjectContext, doSave: Bool = true) {
        let managedObjects = getManagedObjects(in: managedObjectContext, includesPropertyValues: false)
        managedObjects.forEach { managedObjectContext.delete($0 as! NSManagedObject) }
        if doSave { try! managedObjectContext.save() }
    }
    
    // MARK: Database Query Methods
    class func first(in managedObjectContext: NSManagedObjectContext) -> Any? {
        return getManagedObjects(in: managedObjectContext).first
    }
    
    class func lastUpdated(in managedObjectContext: TriviaManagedObjectContext) -> Any? {
        return getManagedObjects(in: managedObjectContext, sortKeys: ["lastUpdatedDate"], isAscending: false, fetchLimit: 1).first
    }
    
    class func getManagedObjects(in managedObjectContext: NSManagedObjectContext, predicate: NSPredicate? = nil, sortKeys: [String]? = nil, isAscending: Bool = true, propertiesToFetch: [String]? = nil, returnsDistinctResults: Bool = false, includesPropertyValues: Bool = true, fetchLimit: Int? = nil) -> [Any] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: NSStringFromClass(self), in: managedObjectContext)
        fetchRequest.predicate = predicate
        setSortKeysInFetchRequest(fetchRequest, isAscending: isAscending, sortKeyNames: sortKeys)
        setPropertiesToFetchInFetchRequest(fetchRequest, propertyNames: propertiesToFetch)
        fetchRequest.returnsDistinctResults = returnsDistinctResults
        fetchRequest.includesPropertyValues = includesPropertyValues
        if let fetchLimit = fetchLimit, fetchLimit > 0 { fetchRequest.fetchLimit = fetchLimit }
        
        let resultsArray = try! managedObjectContext.fetch(fetchRequest)
        return resultsArray as [AnyObject]
    }
    
    fileprivate class func setSortKeysInFetchRequest(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>, isAscending: Bool, sortKeyNames: [String]?) {
        if let sortKeyNames = sortKeyNames {
            fetchRequest.sortDescriptors = [NSSortDescriptor]()
            for sortKeyName in sortKeyNames {
                fetchRequest.sortDescriptors!.append(NSSortDescriptor(key: sortKeyName, ascending: isAscending))
            }
        }
    }
    
    // Using this option will change the resultType to Dictionary
    fileprivate class func setPropertiesToFetchInFetchRequest(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>, propertyNames: [String]?) {
        if let propertyNames = propertyNames {
            let propertiesInEntity = fetchRequest.entity!.propertiesByName
            fetchRequest.propertiesToFetch = [NSPropertyDescription]()
            for propertyName in propertyNames {
                if let property = propertiesInEntity[propertyName] {
                    fetchRequest.propertiesToFetch!.append(property)
                } else { assertionFailure("Property \(propertyName) does not exist in the entity.") }
            }
            fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        }
    }
    
    class func fetchedResultsController(_ managedObjectContext: NSManagedObjectContext, sortKeys: [String], isAscending: Bool = true, predicate: NSPredicate? = nil, batchSize: Int = 20, delegate: NSFetchedResultsControllerDelegate? = nil) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NSStringFromClass(self))
        fetchRequest.fetchBatchSize = batchSize
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor]()
        for sortKey in sortKeys {
            fetchRequest.sortDescriptors?.append(NSSortDescriptor(key: sortKey, ascending: isAscending))
        }
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = delegate
        try! fetchedResultsController.performFetch()
        return fetchedResultsController
    }
    
    class func count(_ predicateString: String? = nil) -> Int {
        let error: Error? = nil
        let managedObjectContext = TriviaManagedObjectContext.managedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NSStringFromClass(self))
        if let predicateString = predicateString {
            fetchRequest.predicate = NSPredicate(format: predicateString)
        }
        fetchRequest.includesPropertyValues = false
        fetchRequest.includesSubentities    = false
        let count = try! managedObjectContext.count(for: fetchRequest)
        assert(error == nil)
        return count
    }
    
    func copyAttributesFromManagedObject(_ fromManagedObject: NSManagedObject) {
        for attribute in fromManagedObject.entity.attributesByName {
            let value: AnyObject? = fromManagedObject.value(forKey: attribute.0) as AnyObject?
            self.setValue(value, forKey: attribute.0)
        }
    }
}
