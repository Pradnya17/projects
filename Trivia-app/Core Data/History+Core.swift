//
//  History+Core.swift
//  Trivia-app
//
//  Created by Pradnya Achari on 21/07/20.
//  Copyright © 2020 Pradnya Achari. All rights reserved.
//

import Foundation
import CoreData

extension History {
    
    //core data extension for accessing, saving data from and to

    class func getHistoryData(managedObjectContext : NSManagedObjectContext) -> History? {
        return History.getManagedObjects(in: managedObjectContext).first as? History
    }
    
    class func saveHistories(data: [HistoryElement]?) {
        let managedObjectContext = TriviaManagedObjectContext.managedObjectContext()
        let historyData = History.getHistoryData(managedObjectContext: managedObjectContext) ?? History.managedObject(managedObjectContext)
        historyData.historyList = nil
        historyData.historyList = HistoryWrapper(data: CachedHistory(data: data))
        try? managedObjectContext.save()
    }
    
    class func getHistoryList() -> [HistoryElement]? {
        let managedObjectContext = TriviaManagedObjectContext.managedObjectContext()
        let historyData = History.getHistoryData(managedObjectContext: managedObjectContext)
        return historyData?.historyList?.data?.data
    }
}

public class HistoryWrapper: NSObject, NSCoding, Codable {
    
    var data        : CachedHistory?
    var interimData : InterimHistory?
    let key         = "Program"
    
    init(data : CachedHistory?) {
        self.data = data
    }
    
    public func encode(with aCoder: NSCoder) {
        if let data = try? JSONEncoder().encode(self) {
            aCoder.encode(String(data: data, encoding: .utf8), forKey: key)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        if let decodableString = aDecoder.decodeObject(forKey: key) as? String {
            let jsonData = Data(decodableString.utf8)
            self.interimData = try? JSONDecoder().decode(InterimHistory.self, from: jsonData)
            self.data        = CachedHistory(interimData: interimData)
        }
    }
}

class CachedHistory: NSObject, Codable {
    let data : [HistoryElement]?
    
    init(data: [HistoryElement]?) {
        self.data = data
    }
    
    init(interimData : InterimHistory?) {
        self.data = interimData?.data?.data
    }
}

class InterimHistory: NSObject, Codable {
    let data : CachedHistory?
    let key  : String
}
