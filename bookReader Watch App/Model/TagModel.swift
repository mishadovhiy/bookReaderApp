//
//  TagModel.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import Foundation

struct TagModel: Codable {
    let title: String
    let id: String
    
    init(title: String, id: String = UUID().uuidString) {
        self.title = title
        self.id = id
    }
}
