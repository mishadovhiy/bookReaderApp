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
            } else if !viewModel.hasError {
                NavigationView {
                    contentView
                }
            } else {
                errorView
            }
        }
        .onAppear {
            viewModel.fetchBook(db: coreDataService)
        }
        .environmentObject(coreDataService)
    }
    
    var contentView: some View {
        ScrollView(.vertical) {
            ChapterPickerView(
                viewModel: viewModel,
                chapterPageView: chapterPageView)
            .background {
                contentSizeReader
            }
        }
        .modifier(BackgroundTextViewModifier(
            text: viewModel.scrollBackgroundText,
            textHelperOverlaySizes: viewModel.backgroundTextOverlay,
            safeArea: $viewModel.safeArea))
        .overlay {
            NavigationLink("", destination: chapterPageView, isActive: $viewModel.isPagePresenting)
                .hidden()
        }
        .onAppear {
            Task(priority: .background) {
                await viewModel.fetchReadingProgress(db: coreDataService, bookID: viewModel.response?.id ?? "")
            }
        }
    }
    
    @ViewBuilder
    var chapterPageView: some View {
        if let book = viewModel.response {
            ParentPageView(book: book, readingProgress: $viewModel.readingProgress, chapterID: viewModel.selectedChapterID)
        }
    }
    
    var contentSizeReader: some View {
        GeometryReader { proxy in
            Color.clear
                .onChange(of: proxy.frame(in: .global)) { newValue in
                    viewModel.scrollPositionChanged(newValue, size: proxy.size)
                }
        }
    }
    
    var errorView: some View {
        Text(viewModel.error?.domain ?? viewModel.defaultContentErrorText)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity,
                   alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding()
    }
}

#Preview {
    HomeView()
}
