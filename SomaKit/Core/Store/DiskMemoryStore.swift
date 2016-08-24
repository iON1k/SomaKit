//
//  DiskMemoryStore.swift
//  SomaKit
//
//  Created by Anton on 28.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class DiskMemoryStore: StoreType {
    public typealias KeyType = String
    public typealias DataType = NSData
    
    private let fileManager = NSFileManager()
    private let baseDirectory: String?
    private let attributes: [String : AnyObject]?
    
    public init(baseDirectory: String? = nil, attributes: [String : AnyObject]? = nil) {
        self.baseDirectory = baseDirectory
        self.attributes = attributes
    }
    
    public func loadData(key: KeyType) throws -> DataType? {
        let path = generatePath(key)
        return fileManager.contentsAtPath(path)
    }
    
    public func saveData(key: KeyType, data: DataType?) throws {
        let path = generatePath(key)
        guard let data = data else {
            try fileManager.removeItemAtPath(path)
            return
        }
        
        fileManager.createFileAtPath(path, contents: data, attributes: attributes)
    }
    
    private func generatePath(key: KeyType) -> String {
        guard let baseDirectory = baseDirectory else {
            return key
        }
        
        return baseDirectory + key
    }
}