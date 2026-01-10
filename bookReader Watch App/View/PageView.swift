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
    @Binding var backGroundsAt: [TagPositionList]
    @StateObject private var viewModel: PageViewModel
    
    init(bookID: String,
         chapter: BookModel.Chapters,
        lastScrollID: Binding<String?>,
         backGroundsAt: Binding<[TagPositionList]>
    ) {
        _viewModel = StateObject(wrappedValue: .init(bookID: bookID, chapter: chapter))
        _lastScrollID = Binding(projectedValue: lastScrollID)
        _backGroundsAt = Binding(projectedValue: backGroundsAt)
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
        .onChange(of: backGroundsAt) { newValue in
            viewModel.reloadAttributedString(backGroundsAt: backGroundsAt)
        }
        .onAppear {
            viewModel.reloadAttributedString(backGroundsAt: backGroundsAt)
        }
        .onChange(of: lastScrollID) { newValue in
            if let lastScrollID, !lastScrollID.isEmpty {
                viewModel.scrollTo = lastScrollID
            }
        }
        .onDisappear {
            self.lastScrollID = viewModel.lastScrollHolder
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
                    viewModel.lastScrollHolder = content.0
                }
                .overlay {
                    GeometryReader { proxy in
                        Color.white.opacity(0.01)
                            .onTapGesture { point in
                                viewModel.didTapWord(parapgaphID: content.0, text: content.1.string, viewWidth: proxy.size.width, tapPosition: point, backGroundsAt: $backGroundsAt, db: db)
                            }
                    }
                    
                }
        }
    }

}

