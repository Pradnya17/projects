//
//  History+CoreDataProperties.swift
//  Trivia-app
//
//  Created by Pradnya Achari on 21/07/20.
//  Copyright © 2020 Pradnya Achari. All rights reserved.
//
//

import Foundation
import CoreData

//File generated for saving to coreData

extension History {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }
    
    @NSManaged public var historyList: HistoryWrapper?
    
}
