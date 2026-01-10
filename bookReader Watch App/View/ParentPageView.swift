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
    @State var higlightedText: [TagPositionList] = []
    @State var selection: String = ""
    @State var firstTimeAppLaunched: Bool = false
    @EnvironmentObject var coreDataService: CoreDataService
    @State var readingProgress: ReadingProgress?
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(book.chapters, id: \.id) { chapter in
                PageView(bookID: book.id, chapter: chapter, lastScrollID: .init(get: {
                    return readingProgress?.paragraphID ?? ""
                }, set: { paragraph in
                    readingProgress?.chapterID = chapter.id
                    readingProgress?.paragraphID = paragraph
                }), backGroundsAt: $higlightedText)
                .id(chapter.id)
            }
        }
        .ignoresSafeArea(.all)
        .onChange(of: selection) { newValue in
            let key = self.book.chapters.first(where: {
                $0.id == selection
            })
            if readingProgress?.chapterID != newValue {
                readingProgress = .init(context: coreDataService.contexts)
                readingProgress?.bookID = book.id
                readingProgress?.chapterID = newValue
            }
            
            print(newValue, " yhrtgrfsd ", key)
            Task {
                let request = TagPositionList.fetchRequest()
                request.predicate = NSPredicate(
                    format: "bookID == %@ AND chapterID == %@",
                    self.book.id, newValue
                )
                let fetch = try? coreDataService.contexts.fetch(request)
                print(fetch, " yhtgerfsd ")
                await MainActor.run {
                    self.higlightedText = fetch ?? []
                }
            }
        }
        .task {
            let request = ReadingProgress.fetchRequest()
            let context = coreDataService.contexts
            let fetch = try? context.fetch(request).first ?? .init(context: context)
            await MainActor.run {
                self.readingProgress = fetch
                readingProgress?.bookID = book.id
                print(readingProgress?.paragraphID, " vjvjyjv", readingProgress?.chapterID)
                self.selection = readingProgress?.chapterID ?? ""
            }
        }
        .onAppear(perform: {
            //load higlihted text, set progress
        })
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onDisappear {
            Task(priority: .background) {
                let context = coreDataService.contexts
                print(readingProgress?.chapterID, " erfedasx")
                let fetchRequest: NSFetchRequest<ReadingProgress> =
                    ReadingProgress.fetchRequest()
                let all = try? context.fetch(fetchRequest)
                all?.forEach {
                    if $0.chapterID != readingProgress?.chapterID {
                        context.delete($0)
                    }
                }
                try? context.save()
            }

        }
    }
}

#Preview {
    ParentPageView(book: .init(id: "", title: "", chapters: []))
}
