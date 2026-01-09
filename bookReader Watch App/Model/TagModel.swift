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
    
    init(title: String) {
        self.title = title
        self.id = UUID().uuidString
    }
}

extension [TagModel] {
    static var demo: Self {
        [
            .init(title: "BookMark")
        ]
    }
}
