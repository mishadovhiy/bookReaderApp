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
                Text(viewModel.error?.domain ?? viewModel.defaultContentErrorText)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity,
                           alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding()
            }
        }
        .onAppear {
            viewModel.fetchBook(db: coreDataService)
        }
        .environmentObject(coreDataService)
    }
    
    var contentView: some View {
        ScrollView(.vertical) {
            VStack() {
                Spacer().frame(height: 50)
                startButton
                Spacer().frame(height: 30)
                Divider()
                    .opacity(0.4)
                chapterContainer
            }
            .padding()
        }
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
    
    var startButton: some View {
        NavigationLink {
            chapterPageView
        } label: {
            Text(viewModel.startButtonTitle)
                .shadow(radius: 5)
        }
        .background(.white)
        .font(.headline)
        .cornerRadius(50)
        .tint(.black)
    }
    
    @ViewBuilder
    var chapterContainer: some View {
        Text("Chapters")
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .font(.footnote)
            .opacity(0.8)
            .foregroundColor(.secondary)
            .padding(.leading, 20)
        VStack(spacing: .zero) {
            chapterTitleList
        }
        .padding(15)
        .background(.white.opacity(0.08))
        .cornerRadius(24)
        .padding(5)
    }
    
    @ViewBuilder
    var chapterTitleList: some View {
        let chapterList = viewModel.chapterList
        ForEach(chapterList, id: \.id) { chapter in
            let isLast = !viewModel.isReadingLast && chapter.id == chapterList.last?.id
            Text(isLast ? "Last Chapter" : chapter.title)
                .opacity(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background.opacity(0.01))
                .frame(height: 40)
                .font(.footnote)
                .multilineTextAlignment(.leading)
                .onTapGesture {
                    viewModel.selectedChapterID = chapter.id
                }
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
