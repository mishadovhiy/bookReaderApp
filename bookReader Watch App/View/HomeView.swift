//
//  ContentView.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel = .init()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                LoadingView()
            } else if let book = viewModel.response {
                ParentPageView(book: book)
            } else {
                Text(viewModel.error?.domain ?? "Unknow error occupied")
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchBook()
        }
    }
}

#Preview {
    HomeView()
}
