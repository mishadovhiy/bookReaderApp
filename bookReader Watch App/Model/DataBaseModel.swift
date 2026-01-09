//
//  DataBaseModel.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import Foundation

struct DataBaseModel: Codable {
    var books: [FetchBookContentRequest: [BookModel]] = [:]
    
    struct Reading: Codable {
        
        var progress: [Progress] = []
        var tags: [TagPositionModel] = []
        
        struct Progress: Codable {
            let bookID: String
            let chapterTextIndex: Int
        }
    }
}
