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
    @State var scrollIDs: [BookModel.Chapters: String] = [:]
    @State var dataBaseService: DataBaseService = .init()
    @State var higlightedText: [String: [String: [Int]]] = [:]
    @State var selection: String = ""
    @State var firstTimeAppLaunched: Bool = false
    @EnvironmentObject var coreDataService: CoreDataService
    @State var readingProgress: ReadingProgress?
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(book.chapters, id: \.id) { chapter in
                PageView(bookID: book.id, chapter: chapter, firstAppLaunched: $firstTimeAppLaunched, lastScrollID: .init(get: {
                    scrollIDs[chapter]
                }, set: { paragraph in
                    scrollIDs.updateValue(paragraph ?? "", forKey: chapter)
                    readingProgress?.bookID = book.id
                    readingProgress?.chapterID = chapter.id
                    readingProgress?.paragraphID = paragraph
                }), backGroundsAt: .init(get: {
                    higlightedText[chapter.id] ?? [:]
                }, set: {
                    higlightedText.updateValue($0, forKey: chapter.id)
                }))
                .id(chapter.id)
            }
        }
        .onChange(of: selection) { newValue in
            let key = self.book.chapters.first(where: {
                $0.id == selection
            })
            print(newValue, " yhrtgrfsd ", key)

        }
        .task {
            let request = ReadingProgress.fetchRequest()
            guard let context = coreDataService.contexts[.readingProgress] else {
                fatalError()
            }
            let fetch = try? context.fetch(request).first ?? .init(context: context)
            await MainActor.run {
                self.readingProgress = fetch
                print(readingProgress?.chapterID)
                self.selection = readingProgress?.chapterID ?? ""
            }
//            let db = coreDataService.contexts[.readingProgress]?.fetch(.init())
//            //dataBaseService.dataBase?.reading
//            print(db, " jhbjhbjhb")
//            await MainActor.run {
//                if let key = self.book.chapters.first(where: {
//                    $0.id == db?.
//                }) {
//                    self.scrollIDs.updateValue(db?.progress?.paragraphID ?? "", forKey: key)
//                    print(key.id, " bjukbkuhkub ")
//                    self.selection = key.id
//
//                }
//            }
        }
        .onAppear(perform: {
            //load higlihted text, set progress
        })
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onDisappear {
            Task(priority: .background) {
                guard let context = coreDataService.contexts[.readingProgress] else {
                    return
                }
                try? context.save()
            }
//            Task(priority: .utility) {
//                if let key = self.book.chapters.first(where: {
//                    $0.id == selection
//                }) {
//                    dataBaseService.dataBase?.reading.progress = .init(bookID: book.id, chapterID: selection, paragraphID: self.scrollIDs[key] ?? "")
//print(key, " bjukbkuhkub ")
//                }
//            }
        }
    }
}

#Preview {
    ParentPageView(book: .init(id: "", title: "", chapters: []))
}
