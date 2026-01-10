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
                        .shadow(radius: 5)
                }
                .background(.white)
                .font(.headline)
                .cornerRadius(50)
                .tint(.black)
                Spacer().frame(height: 30)
                Divider()
                    .opacity(0.4)
                Text("Chapters")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .font(.footnote)
                    .opacity(0.8)
                    .foregroundColor(.secondary)
                    .padding(.leading, 20)
                VStack(spacing: .zero) {
                    
                    ForEach(viewModel.response?.chapters ?? [], id: \.id) { chapter in

                        Text(chapter.title)
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
                .padding(15)
                .background(.white.opacity(0.08))
                .cornerRadius(24)
                .padding(5)
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
