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
        
        init(request data: any Requestable) throws {
            let requestType = type(of: data)
            let stringURL = Key.serverURL.rawValue + requestType.path
            guard let url = URL(string: stringURL) else {
                throw NSError(domain: "Error creating url", code: URLError.badURL.rawValue)
            }
            request = .init(url: url, cachePolicy: requestType.isCacheable ? .returnCacheDataElseLoad : .reloadIgnoringLocalAndRemoteCacheData)
        }
    }
}
