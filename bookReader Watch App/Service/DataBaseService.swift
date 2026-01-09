//
//  FileManagerService.swift
//  bookReader Watch App
//
//  Created by Mykhailo Dovhyi on 09.01.2026.
//

import Foundation

struct DataBaseService {
    private let coreFileManager: CoreFileManager = .init()
    
    var dataBase: DataBaseModel? {
        get {
            fetch(directory: .dataBase) as? DataBaseModel
        }
        set {
            write(newValue ?? .init(), directory: .dataBase)
        }
    }
    
    func write(_ data: Codable, directory: DirectoryType = .dataBase, url: URLType = .local) {
        do {
            guard let url = url.url else {
#if DEBUG
                print("no provided url", #file, #function, #line)
#endif
                return
            }
            let data = try JSONEncoder().encode(data)
            let error = try coreFileManager.writeData(data, directory: directory.rawValue, url: url)
            if let error {
#if DEBUG
                print(error, #file, #function, #line)
#endif
            }
        } catch {
#if DEBUG
            print(error, #file, #function, #line)
#endif
            return
        }
    }
    
    func fetch(directory: DirectoryType = .dataBase, url: URLType = .local) -> Codable? {
        guard let url = url.url else {
#if DEBUG
            print("no provided url", #file, #function, #line)
#endif
            return nil
        }

        do {
            let data = try coreFileManager.fetchData(url: url, directory: directory.rawValue)
            
            let dataModel = try JSONDecoder().decode(directory.responseType, from: data ?? .init())
            return dataModel
        } catch {
#if DEBUG
            print(error, #file, #function, #line)
#endif
            return nil
        }
    }
}

extension DataBaseService {
    
    struct CoreFileManager {
        func writeData(_ data: Data,
                       directory: String,
                       url: URL) throws -> Error? {
            let url = url.appendingPathComponent(directory)
            do {
                try FileManager.default.createDirectory(
                    at: url,
                    withIntermediateDirectories: true
                )
                return nil
            } catch {
                throw error
            }
        }
        
        func fetchData(url: URL, directory: String) throws -> Data? {
            let url = url.appendingPathComponent(directory)
            return try Data(contentsOf: url)
        }
    }
    
    enum DirectoryType: String {
        case dataBase
        
        var responseType: Codable.Type {
            switch self {
            case .dataBase:
                DataBaseModel.self
            }
        }
    }
    
    enum URLType {
        case cloud
        case local
        
        var url: URL? {
            switch self {
            case .cloud:
                FileManager.default.url(
                    forUbiquityContainerIdentifier: nil
                )?.appendingPathComponent("Documents")
            case .local:
                FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                ).first
            }
        }
    }
}
