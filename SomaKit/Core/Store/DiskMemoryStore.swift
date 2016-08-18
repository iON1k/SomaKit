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
    
    public func loadData(key: KeyType) throws -> DataType? {
        return NSData(contentsOfFile: key)
    }
    
    public func saveData(key: KeyType, data: DataType) throws {
        data.writeToFile(key, atomically: true)
    }
}