//
//  ParentPageView.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import SwiftUI
import CoreData

struct ParentPageView: View {
    let book: BookModel
    @EnvironmentObject var coreDataService: CoreDataService

    @State var scrollIDs: [BookModel.Chapters: String] = [:]
    @State var higlightedText: [TagPositionList] = []
    @State var selection: String = ""
    @State var firstTimeAppLaunched: Bool = false
    @State var readingProgress: ReadingProgress?
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(book.chapters, id: \.id) { chapter in
                PageView(bookID: book.id, chapter: chapter, lastScrollID: .init(get: {
                    return readingProgress?.paragraphID ?? ""
                }, set: { paragraph in
                    readingProgress?.chapterID = chapter.id
                    readingProgress?.paragraphID = paragraph
                }), tapPositions: $higlightedText)
                .id(chapter.id)
            }
        }
        .ignoresSafeArea(.all)
        .onChange(of: selection) { newValue in
            let key = self.book.chapters.first(where: {
                $0.id == selection
            })
            if readingProgress?.chapterID != newValue {
                readingProgress = .init(context: coreDataService.context)
                readingProgress?.bookID = book.id
                readingProgress?.chapterID = newValue
            }
            
            print(newValue, " yhrtgrfsd ", key)
            Task {
                await MainActor.run {
                    self.higlightedText = coreDataService.fetchTapPositions(bookID: self.book.id, chapterID: newValue) ?? []
                }
            }
        }
        .task {
            let request = ReadingProgress.fetchRequest()
            let fetch = try? coreDataService.context
                .fetch(request).first ?? .init(
                    context: coreDataService.context)
            await MainActor.run {
                self.readingProgress = fetch
                readingProgress?.bookID = book.id
                self.selection = readingProgress?.chapterID ?? ""
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onDisappear {
            Task(priority: .background) {
                coreDataService.save(savingReadingList: self.readingProgress)
            }

        }
    }
}

#Preview {
    ParentPageView(book: .init(id: "", title: "", chapters: []))
}
