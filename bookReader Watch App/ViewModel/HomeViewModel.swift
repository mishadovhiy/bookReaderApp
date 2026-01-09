//
//  HomeViewModel.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var response: BookModel?
    @Published var error: NSError?
    private let dataBaseService: DataBaseService = .init()
    
    var isLoading: Bool {
        ![
            error == nil,
            response == nil
        ].contains(false)
    }
    
    func fetchBook() {
        error = nil
        Task(priority: .background) {
            let request: FetchBookContentRequest = .init()
            if let booksDB = dataBaseService.dataBase?.books[request] {
                await MainActor.run {
                    self.response = booksDB
                }
                return
            }
            let response = await NetworkService().startTask(request)
            await MainActor.run {
                switch response {
                case .success(let response):
                    self.response = response
                case .failure(let error):
                    self.error = error as NSError
                }
            }
        }
    }
}
