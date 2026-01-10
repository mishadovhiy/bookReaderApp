//
//  ChapterPickerView.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 10.01.2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel = .init()
    @StateObject var coreDataService: CoreDataService = .init()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                LoadingView()
            } else if let book = viewModel.response,
                let readingProgress = viewModel.readingProgress
            {
                NavigationView {
                    chapterList
                }
                
            } else {
                Text(viewModel.error?.domain ?? "Unknow error occupied")
                    .padding()

            }
        }
        .onAppear {
            viewModel.fetchBook(db: coreDataService)
        }
        .environmentObject(coreDataService)
    }
    
    var chapterList: some View {
        ScrollView(.vertical) {
            VStack() {
                Spacer().frame(height: 50)
                NavigationLink {
                    chapterPageView
                } label: {
                    Text(viewModel.startButtonTitle)
                }
                Spacer().frame(height: 10)
                Divider()
                VStack {
                    Text("Chapters")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    ForEach(viewModel.response?.chapters ?? [], id: \.id) { chapter in
                        Button(chapter.title) {
                            viewModel.selectedChapterID = chapter.id
                        }
                    }
                }
            }
            .padding()
        }
        .overlay {
            NavigationLink("", destination: chapterPageView, isActive: $viewModel.isPagePresenting)
                .hidden()
        }
    }
    
    @ViewBuilder
    var chapterPageView: some View {
        if let book = viewModel.response {
            ParentPageView(book: book, readingProgress: viewModel.readingProgress, chapterID: viewModel.selectedChapterID)
        }
    }
}

#Preview {
    HomeView()
}
