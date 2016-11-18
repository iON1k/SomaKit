//
//  FakeStore.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class FakeStore<TKey, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    
    private let defaultValue: DataType?
    
    public func loadData(key: TKey) -> Observable<TData?> {
        return Observable.just(defaultValue)
    }
    
    public func storeData(key: TKey, data: TData?) -> Observable<Void> {
        return Observable.just()
    }
    
    public init(defaultValue: DataType? = nil) {
        self.defaultValue = defaultValue
    }
}
