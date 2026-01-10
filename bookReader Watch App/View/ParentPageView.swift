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
    @StateObject var viewModel: ParentPageViewModel = .init()
    
    var body: some View {
        TabView(selection: $viewModel.selection) {
            ForEach(book.chapters, id: \.id) { chapter in
                PageView(bookID: book.id, chapter: chapter, readingProgress: $viewModel.readingProgress, tapPositions: $viewModel.higlightedText)
                .id(chapter.id)
            }
        }
        .ignoresSafeArea(.all)
        .onChange(of: viewModel.selection) { newValue in
            viewModel.selectionDidChange(book: book, db: coreDataService)
        }
        .task {
            await viewModel.fetchReadingProgress(db: coreDataService, bookID: book.id)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onDisappear {
            Task(priority: .background) {
                coreDataService.save(savingReadingList: self.viewModel.readingProgress)
            }

        }
    }
}

#Preview {
    ParentPageView(book: .init(id: "", title: "", chapters: []))
}
