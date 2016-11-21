//
//  StoreType.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol StoreType {
    associatedtype KeyType
    associatedtype DataType
    
    func loadData(key: KeyType) -> Observable<DataType?>
    func storeData(key: KeyType, data: DataType?) -> Observable<Void>
    
    func asStore() -> Store<KeyType, DataType>
}

extension StoreType {
    public func asStore() -> Store<KeyType, DataType> {
        return Store(loadData, storeData)
    }
}
