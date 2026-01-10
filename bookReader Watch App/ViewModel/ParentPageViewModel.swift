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
    @Published var readingProgress: ReadingProgress?
    
    init(readingProgress: ReadingProgress?) {
        self.readingProgress = readingProgress
    }
    
    var tabViewSelection: String {
        get {
            readingProgress?.chapterID ?? ""
        }
        set {
            readingProgress?.chapterID = newValue
        }
    }
    
    func selectionDidChange(book: BookModel, db: CoreDataService) {
        if readingProgress?.chapterID != tabViewSelection {
            readingProgress = .init(context: db.context)
            readingProgress?.bookID = book.id
            readingProgress?.chapterID = tabViewSelection
        }
        
        self.higlightedText = db.fetchTapPositions(bookID: book.id, chapterID: tabViewSelection) ?? []
    }
}
