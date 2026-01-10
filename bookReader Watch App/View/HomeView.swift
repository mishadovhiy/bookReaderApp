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
            .padding(10)
            .background(.black)
            .compositingGroup()
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
    
    var startButton: some View {
        NavigationLink {
            chapterPageView
        } label: {
            Text(viewModel.startButtonTitle)
                .shadow(radius: 8)
        }
        .background(content: {
            ZStack {
                Color.red
                    .blendMode(.destinationOut)
                Color.white.opacity(0.85)
                    .blur(radius: 5)
            }
        })
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
            .padding(.leading, 10)
        VStack(spacing: .zero) {
            chapterTitleList
        }
        .padding(.vertical, 5)
        .padding(.leading, 15)
        .padding(.trailing, 10)
        .background(.white.opacity(0.08))
        .cornerRadius(24)
        .padding(.horizontal, -5)
    }
    
    @ViewBuilder
    var chapterTitleList: some View {
        let chapterList = viewModel.chapterList
        ForEach(chapterList, id: \.id) { chapter in
            let isLast = !viewModel.isReadingLast && chapter.id == chapterList.last?.id
            HStack {
                Text(isLast ? "Last Chapter" : chapter.title)
                    .opacity(0.8)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                chapterTagCount(chapterID: chapter.id)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(.background.opacity(0.01))
            .compositingGroup()
            .onTapGesture {
                viewModel.selectedChapterID = chapter.id
            }
        }
    }
    
    @ViewBuilder
    func chapterTagCount(chapterID: String) -> some View {
        if let tagCount = viewModel.tagCount[chapterID],
            tagCount >= 1 {
            Text("\(tagCount)")
                .blendMode(.destinationOut)
                .font(.footnote)
                .foregroundColor(.red)
                .minimumScaleFactor(0.2)
                .multilineTextAlignment(.center)
                .frame(width: 12, height: 12)
                .background(.white.opacity(0.2))
                .cornerRadius(6)
                .shadow(radius: 6)
                .padding(.top, -2)
        }
    }
    
    @ViewBuilder
    var chapterPageView: some View {
        if let book = viewModel.response {
            ParentPageView(book: book, readingProgress: viewModel.readingProgress, chapterID: viewModel.selectedChapterID)
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
}

#Preview {
    HomeView()
}
