//
//  ParentPageView.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import SwiftUI

struct ParentPageView: View {
    
    let book: BookModel
    @EnvironmentObject var coreDataService: CoreDataService
    @StateObject var viewModel: ParentPageViewModel
    
    init(book: BookModel,
         readingProgress: Binding<ReadingProgress?>,
         chapterID: String?) {
        self.book = book
        if let chapterID {
            readingProgress.wrappedValue?.chapterID = chapterID
        }
        _viewModel = StateObject(wrappedValue: .init(readingProgress: readingProgress))
    }
    
    var body: some View {
        TabView(selection: $viewModel.tabViewSelection) {
            ForEach(book.chapters, id: \.id) { chapter in
                PageView(bookID: book.id, chapter: chapter, readingProgress: $viewModel.readingProgress, tapPositions: $viewModel.higlightedText)
                .id(chapter.id)
            }
        }
        .ignoresSafeArea(.all)
        .onChange(of: viewModel.tabViewSelection) { newValue in
            viewModel.selectionDidChange(book: book, db: coreDataService)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onAppear(perform: {
            viewModel.selectionDidChange(book: book, db: coreDataService)
        })
        .onDisappear {
            print(self.viewModel.readingProgress?.chapterID, " nkjerfnkudwfn ")
            Task(priority: .background) {
                coreDataService.save(savingReadingList: self.viewModel.readingProgress)
            }
        }
    }
}

