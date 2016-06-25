//
//  StoreType.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol StoreType {
    associatedtype KeyType
    associatedtype DataType
    
    func loadData(key: KeyType) throws -> DataType?
    func saveData(key: KeyType, data: DataType) throws
}