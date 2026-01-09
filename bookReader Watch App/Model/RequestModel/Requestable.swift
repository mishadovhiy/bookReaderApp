//
//  Requestable.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import Foundation

protocol Requestable {
    associatedtype Response: Codable
    static var method: String { get }
    static var path: String { get }
}
