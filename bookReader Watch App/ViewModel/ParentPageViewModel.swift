//
//  ParentPageViewModel.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 10.01.2026.
//

import Foundation
import Combine
import CoreData

class ParentPageViewModel: ObservableObject {
    @Published var scrollIDs: [BookModel.Chapters: String] = [:]
    @Published var higlightedText: [TagPositionList] = []
    @Published var selection: String = ""
    @Published var firstTimeAppLaunched: Bool = false
    @Published var readingProgress: ReadingProgress?
    
    func selectionDidChange(book: BookModel, db: CoreDataService) {
        let key = book.chapters.first(where: {
            $0.id == selection
        })
        if readingProgress?.chapterID != selection {
        
            readingProgress = .init(context: db.context)
            readingProgress?.bookID = book.id
            readingProgress?.chapterID = selection
        }
        
        self.higlightedText = db.fetchTapPositions(bookID: book.id, chapterID: selection) ?? []
    }
    
    func fetchReadingProgress(db: CoreDataService, bookID: String) async {
        let request = ReadingProgress.fetchRequest()
        let fetch = try? db.context
            .fetch(request).first ?? .init(
                context: db.context)
        await MainActor.run {
            self.readingProgress = fetch
            readingProgress?.bookID = bookID
            self.selection = readingProgress?.chapterID ?? ""
        }
    }
}
