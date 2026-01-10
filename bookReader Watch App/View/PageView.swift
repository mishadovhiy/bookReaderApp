//
//  PageView.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import SwiftUI

struct PageView: View {
    
    @EnvironmentObject var coreDataService: CoreDataService
    @Binding var readingProgress: ReadingProgress?
    @Binding var tapPositions: [TagPositionList]
    @StateObject private var viewModel: PageViewModel
    
    init(bookID: String,
         chapter: BookModel.Chapters,
         readingProgress: Binding<ReadingProgress?>,
         tapPositions: Binding<[TagPositionList]>
    ) {
        _viewModel = StateObject(wrappedValue: .init(bookID: bookID, chapter: chapter))
        _readingProgress = Binding(projectedValue: readingProgress)
        _tapPositions = Binding(projectedValue: tapPositions)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            ScrollViewReader { scrollProxy in
                contentView(scrollProxy)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: tapPositions) { newValue in
            viewModel.reloadAttributedString(tagPosition: tapPositions)
        }
        .onAppear {
            viewModel.reloadAttributedString(tagPosition: tapPositions)
            if let lastScrollID = readingProgress?.paragraphID, !lastScrollID.isEmpty {
                viewModel.scrollTo = lastScrollID
            }
        }
        .onDisappear {
            self.readingProgress?.paragraphID = viewModel.lastVisibleParagraph
        }
    }
    
    func contentView(_ scrollProxy: ScrollViewProxy) -> some View {
        LazyVStack(spacing: 10, content: {
            Text(viewModel.chapter.title)
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            textListView
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .onChange(of: viewModel.scrollTo) { newValue in
            if let newValue {
                scrollProxy.scrollTo(newValue)
                self.viewModel.scrollTo = nil
            }
        }
    }
    
    var textListView: some View {
        ForEach(viewModel.paragraphs, id: \.paragraphID) { content in
            Text(.init(content.attributedString))
                .opacity(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: viewModel.textFontSize.pointSize))
                .multilineTextAlignment(.leading)
                .id(content.paragraphID)
                .onDisappear {
                    viewModel.lastVisibleParagraph = content.paragraphID
                }
                .overlay {
                    textTapOverlay(content)
                }
        }
    }
    
    func textTapOverlay(_ content: PageViewModel.ParagraphText) -> some View {
        GeometryReader { proxy in
            Color.white.opacity(0.01)
                .onTapGesture { point in
                    viewModel.didTapWord(
                        parapgaphID: content.paragraphID,
                        text: content.attributedString.string,
                        viewWidth: proxy.size.width,
                        tapPosition: point,
                        tagPosition: $tapPositions,
                        db: coreDataService)
                }
        }
    }
}

#Preview {
    PageView(bookID: "001",
             chapter: .demo,
             readingProgress: .constant(nil),
             tapPositions: .constant([]))
}
