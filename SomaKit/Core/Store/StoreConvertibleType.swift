//
//  StoreConvertibleType.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol StoreConvertibleType {
    associatedtype KeyType
    associatedtype DataType
    
    func asStore() -> AnyStore<KeyType, DataType>
}
