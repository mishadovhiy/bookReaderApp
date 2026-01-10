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
    @MainActor @Published var tagCount: [String: Int] = [:]
    
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
    
    var hasError: Bool {
        [
            response != nil,
            readingProgress != nil
        ].contains(false)
    }
    
    let defaultContentErrorText = "Unknow error occupied"
    
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
        await fetchTagCount(db: db)
        
        await MainActor.run {
            readingProgress = fetch
            readingProgress?.bookID = bookID
        }
    }
    
    private func fetchTagCount(db: CoreDataService) async {
        let request = TagPositionList.fetchRequest()
        let fetch = try? db.context.fetch(request)
        
        let chapterIDs = response?.chapters.compactMap({$0.id}) ?? []
        var tagCount = self.tagCount
        tagCount.removeAll()
        
        fetch?.forEach { tag in
            let count = tagCount[tag.chapterID ?? ""] ?? 0
            tagCount.updateValue(count + 1, forKey: tag.chapterID ?? "")
        }
        self.tagCount = tagCount
    }
    
    var startButtonTitle: String {
        (readingProgress?.chapterID == nil ? "Start" : "Continiue") + " " + "reading"
    }
    
    var isReadingLast: Bool {
        response?.chapters.last?.id == readingProgress?.chapterID
    }
    
    var chapterList: [BookModel.Chapters] {
        let chapters = response?.chapters ?? []
        let removeID = self.readingProgress?.chapterID ?? chapters.first?.id
        return Array(chapters.filter({
            $0.id != removeID
        }))
    }
    
    var scrollBackgroundText: String {
        response?.chapters.compactMap({
            $0.paragraphs.compactMap({
                $0.content
            })
            .joined(separator: " ")
        }).joined(separator: " ") ?? ""
    }
}
