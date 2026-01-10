//
//  PageView.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import SwiftUI
import CoreData

struct PageView: View {
    
    @EnvironmentObject var db: CoreDataService
    @Binding var lastScrollID: String?
    @Binding var tapPositions: [TagPositionList]
    @StateObject private var viewModel: PageViewModel
    
    init(bookID: String,
         chapter: BookModel.Chapters,
        lastScrollID: Binding<String?>,
         tapPositions: Binding<[TagPositionList]>
    ) {
        _viewModel = StateObject(wrappedValue: .init(bookID: bookID, chapter: chapter))
        _lastScrollID = Binding(projectedValue: lastScrollID)
        _tapPositions = Binding(projectedValue: tapPositions)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            ScrollViewReader { scrollProxy in
                LazyVStack(spacing: 10, content: {
                    Text(viewModel.chapter.title)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                    textListView
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: viewModel.scrollTo) { newValue in
                    if let newValue {
                        scrollProxy.scrollTo(newValue)
                        self.viewModel.scrollTo = nil
                    }
                }
            }
        }
        .onChange(of: tapPositions) { newValue in
            viewModel.reloadAttributedString(backGroundsAt: tapPositions)
        }
        .onAppear {
            viewModel.reloadAttributedString(backGroundsAt: tapPositions)
        }
        .onChange(of: lastScrollID) { newValue in
            if let lastScrollID, !lastScrollID.isEmpty {
                viewModel.scrollTo = lastScrollID
            }
        }
        .onDisappear {
            self.lastScrollID = viewModel.lastVisibleParagraph
        }
    }
    
    var textListView: some View {
        ForEach(viewModel.contents, id: \.0) { content in
            Text(.init(content.1))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: viewModel.textFontSize.pointSize))
                .multilineTextAlignment(.leading)
                .id(content.0)
                .onDisappear {
                    viewModel.lastVisibleParagraph = content.0
                }
                .overlay {
                    GeometryReader { proxy in
                        Color.white.opacity(0.01)
                            .onTapGesture { point in
                                viewModel.didTapWord(parapgaphID: content.0, text: content.1.string, viewWidth: proxy.size.width, tapPosition: point, backGroundsAt: $tapPositions, db: db)
                            }
                    }
                    
                }
        }
    }

}

