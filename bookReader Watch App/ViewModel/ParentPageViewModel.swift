//
//  ParentPageViewModel.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 10.01.2026.
//

import Foundation
import Combine
import CoreData
import SwiftUI

class ParentPageViewModel: ObservableObject {
    
    @Published var scrollIDs: [BookModel.Chapters: String] = [:]
    @Published var higlightedText: [TagPositionList] = []
    @Binding var readingProgress: ReadingProgress?
    
    init(readingProgress: Binding<ReadingProgress?>) {
        self._readingProgress = Binding(projectedValue: readingProgress)
        self.tabViewSelection = readingProgress.wrappedValue?.chapterID ?? ""
    }
    
    @Published var tabViewSelection: String
    
    func selectionDidChange(book: BookModel, db: CoreDataService) {
        print(tabViewSelection, " gtfsasdfgsd ")
        if readingProgress?.chapterID != tabViewSelection {
            readingProgress = .init(context: db.context)
            readingProgress?.bookID = book.id
            readingProgress?.chapterID = tabViewSelection
        }
        
        self.higlightedText = db.fetchTapPositions(bookID: book.id, chapterID: tabViewSelection) ?? []
    }
}
