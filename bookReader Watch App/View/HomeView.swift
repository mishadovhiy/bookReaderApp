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
            } else if let book = viewModel.response {
                NavigationView {
                    ScrollView(.vertical) {
                        VStack {
                            NavigationLink {
                                ParentPageView(book: book)
                            } label: {
                                Text("Open")
                            }

                        }
                    }
                }
                
            } else {
                Text(viewModel.error?.domain ?? "Unknow error occupied")
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchBook()
        }
        .environmentObject(coreDataService)
    }
}

#Preview {
    HomeView()
}
