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
    private let attributes: [String : AnyObject]?
    
    public init(attributes: [String : AnyObject]? = nil) {
        self.attributes = attributes
    }
    
    public func loadData(key: KeyType) throws -> DataType? {
        return fileManager.contentsAtPath(key)
    }
    
    public func saveData(key: KeyType, data: DataType?) throws {
        guard let data = data else {
            try fileManager.removeItemAtPath(key)
            return
        }
        
        fileManager.createFileAtPath(key, contents: data, attributes: attributes)
    }
}