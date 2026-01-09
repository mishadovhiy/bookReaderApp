//
//  FetchBookContentRequest.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import Foundation

struct FetchBookContentRequest: Requestable, Hashable, Codable {
    typealias Response = BookModel
    
    static var method: String { "GET" }
    
    /// demo url path
    /// after completing API Request on Back End side: change path to the path of the Request URL last component (example: "book/fetchContent.php"), and add parameter id to the FetchBookContentRequest
    static var path: String { "book1.json" }
    
    
}

