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
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    init() {
        self.container = .init(name: "AppData")
        container.loadPersistentStores { description, error in }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save(savingReadingList: ReadingProgress?) {
        let fetchRequest: NSFetchRequest<ReadingProgress> =
            ReadingProgress.fetchRequest()
        let all = try? context.fetch(fetchRequest)
        all?.forEach {
            if $0.chapterID != savingReadingList?.chapterID {
                context.delete($0)
            }
        }
        try? context.save()
    }
    
    func fetchTapPositions(
        bookID: String,
        chapterID: String
    ) -> [TagPositionList]? {
        fetchTagPositions(predicate: .init(
            format: "bookID == %@ AND chapterID == %@",
            bookID, chapterID
        ))
    }
    
    func fetchAllTagPositions() -> [TagPositionList]? {
        return fetchTagPositions()
    }
    
    private func fetchTagPositions(predicate: NSPredicate? = nil) -> [TagPositionList]? {
        let request = TagPositionList.fetchRequest()
        request.predicate = predicate
        return try? context.fetch(request)
    }
}
