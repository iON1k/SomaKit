//
//  Store.swift
//  SomaKit
//
//  Created by Anton on 05.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

open class Store<TKey, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    
    public typealias LoadDataHandler = (KeyType) -> Observable<TData?>
    public typealias SaveDataHandler = (KeyType, DataType?) -> Observable<Void>
    
    private let loadDataHandler: LoadDataHandler
    private let saveDataHandler: SaveDataHandler
    
    public func loadData(key: TKey) -> Observable<TData?> {
        return loadDataHandler(key)
    }
    
    public func storeData(key: TKey, data: TData?) -> Observable<Void> {
        return saveDataHandler(key, data)
    }
    
    public init(_ loadDataHandler: @escaping LoadDataHandler, _ saveDataHandler: @escaping SaveDataHandler) {
        self.loadDataHandler = loadDataHandler
        self.saveDataHandler = saveDataHandler
    }
}

extension Store {
    public func asStore() -> Store<KeyType, DataType> {
        return self
    }
}
