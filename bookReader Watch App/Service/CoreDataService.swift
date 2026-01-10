//
//  CoreDataService.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 10.01.2026.
//

import Foundation
import CoreData
import Combine

class CoreDataService: ObservableObject {
    
    enum DataModelIdType: String, CaseIterable {
        case readingProgress
        
        var entityName: String {
            return (rawValue.first?.uppercased() ?? "") + rawValue.dropFirst()
        }
    }
    
    let container: [DataModelIdType: NSPersistentContainer]
    var contexts: [DataModelIdType: NSManagedObjectContext] {
        container.compactMapValues { container in
            container.viewContext
        }
    }
    
    init() {
        self.container = .init(uniqueKeysWithValues: DataModelIdType.allCases.compactMap({
            ($0, NSPersistentContainer(name: $0.entityName))
        }))
        container.forEach {
            $0.value.loadPersistentStores { description, error in
                
            }
            $0.value.viewContext.automaticallyMergesChangesFromParent = true
        }
    }
    
    func fetch() {
        let request = ReadingProgress.fetchRequest()
        let allData = try? self.contexts[.readingProgress]?.fetch(.init())
    }
}
