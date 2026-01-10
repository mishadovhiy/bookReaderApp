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
    
    let container: NSPersistentContainer
    var contexts: NSManagedObjectContext {
        container.viewContext
    }
    
    init() {
        self.container = .init(name: "AppData")
        container.loadPersistentStores { description, error in }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
