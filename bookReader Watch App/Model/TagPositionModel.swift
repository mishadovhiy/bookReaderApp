//
//  TagPositionModel.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import Foundation

struct TagPositionModel: Codable {
    let bookID: String
    let chapterTextIndex: Int
    let tag: TagModel
}
