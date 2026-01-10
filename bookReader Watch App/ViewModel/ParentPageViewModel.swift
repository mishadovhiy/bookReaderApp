//
//  ParentPageViewModel.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 10.01.2026.
//

import Foundation
import Combine
import CoreData
import Combine
import SwiftUI

class ParentPageViewModel: ObservableObject {
    @Published var scrollIDs: [BookModel.Chapters: String] = [:]
    @Published var higlightedText: [TagPositionList] = []
    var selection: String {
        get {
            readingProgress?.chapterID ?? ""
        }
        set {
            readingProgress?.chapterID = newValue
        }
    }
    @Published var readingProgress: ReadingProgress?
    
    init(readingProgress: ReadingProgress?) {
        self.readingProgress = readingProgress
    }
    
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
}
