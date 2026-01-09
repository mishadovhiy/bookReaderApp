//
//  RequestBuilder.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import Foundation

extension NetworkService {
    struct RequestBuilder {
        
        let request: URLRequest
        
        init(request: Requestable) {
            self.request = request
        }
    }
}
