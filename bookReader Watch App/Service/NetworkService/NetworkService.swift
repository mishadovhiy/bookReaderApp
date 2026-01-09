//
//  NetworkService.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import Foundation

struct NetworkService {
    func startTask<Request: Requestable>(
        _ requestable: Request
    ) async -> Result<Request.Response, Error> {
        do {
            let request = try RequestBuilder(request: requestable)
            let response = try await perform(request: request.request)
            let result = try JSONDecoder().decode(Request.Response.self, from: response)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    private func perform(request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                throw NSError(domain: NSURLErrorDomain, code: URLError.badServerResponse.rawValue)
            }
            let error = try? JSONDecoder()
                .decode(ErrorNetworkResponse.self, from: data)
            if let error {
                throw NSError(domain: error.message, code: URLError.errorDomain.hashValue)
            }
            return data
        } catch {
            throw error
        }
    }
}
