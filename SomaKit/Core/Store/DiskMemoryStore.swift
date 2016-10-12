//
//  DiskMemoryStore.swift
//  SomaKit
//
//  Created by Anton on 28.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

open class DiskMemoryStore: StoreType {
    public typealias KeyType = String
    public typealias DataType = Data
    
    public typealias AttributesType = [String : Any]
    
    fileprivate let fileManager = FileManager()
    fileprivate let baseDirectory: String?
    fileprivate let attributes: AttributesType?
    
    public init(baseDirectory: String? = nil, attributes: AttributesType? = nil) {
        self.baseDirectory = baseDirectory
        self.attributes = attributes
    }
    
    open func loadData(_ key: KeyType) throws -> DataType? {
        let path = generatePath(key)
        return fileManager.contents(atPath: path)
    }
    
    open func saveData(_ key: KeyType, data: DataType?) throws {
        let path = generatePath(key)
        guard let data = data else {
            try fileManager.removeItem(atPath: path)
            return
        }
        
        fileManager.createFile(atPath: path, contents: data, attributes: attributes)
    }
    
    fileprivate func generatePath(_ key: KeyType) -> String {
        guard let baseDirectory = baseDirectory else {
            return key
        }
        
        return baseDirectory + key
    }
}
