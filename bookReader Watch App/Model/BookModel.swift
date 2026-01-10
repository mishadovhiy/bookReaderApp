//
//  BookModel.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import Foundation

struct BookModel: Codable {
    let id: String
    let title: String
    let chapters: [Chapters]
    
    struct Chapters: Codable, Hashable {
        let id: String
        let title: String
        let paragraphs: [Paragraphs]
        
        struct Paragraphs: Codable, Hashable {
            let id: String
            let content: String
        }
    }
}

extension BookModel.Chapters {
    static var demo: Self {
        .init(id: "001", title: "Chapter title #1", paragraphs: [
            .init(id: "01", content: "some content"),
            .init(id: "02", content: "some content 2")
        ])
    }
}
