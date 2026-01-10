//
//  HomeViewModel.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import Foundation
import Combine
import CoreData

class HomeViewModel: ObservableObject {
    @MainActor @Published var response: BookModel?
    
    @MainActor @Published var error: NSError?
    @Published var readingProgress: ReadingProgress?
    @Published var selectedChapterID: String?
    
    var isPagePresenting: Bool {
        get {
            selectedChapterID != nil
        }
        set {
            if !newValue {
                selectedChapterID = nil
            }
        }
    }
    var isLoading: Bool {
        ![
            error == nil,
            response == nil
        ].contains(false)
    }
    
    func fetchBook(db: CoreDataService) {
        error = nil
        Task(priority: .background) {
            let response = await NetworkService().startTask(FetchBookContentRequest())
            
            switch response {
            case .success(let response):
                await self.fetchReadingProgress(db: db, bookID: response.id)
                self.response = response
            case .failure(let error):
                self.error = error as NSError
            }
        }
    }
    
    func fetchReadingProgress(db: CoreDataService, bookID: String) async {
        let request = ReadingProgress.fetchRequest()
        let fetch = try? db.context
            .fetch(request).first ?? .init(
                context: db.context)
        await MainActor.run {
            self.readingProgress = fetch
            readingProgress?.bookID = bookID
        }
    }
    
    var startButtonTitle: String {
        (readingProgress?.chapterID == nil ? "Start" : "Continiue") + " " + "reading"
    }
}
