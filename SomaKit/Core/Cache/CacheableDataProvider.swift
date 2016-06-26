//
//  CacheableDataProvider.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public enum CacheableDataProviderMode {
    case CacheWithData
    case OnlyCache
    case NoCache
}

public class CacheableDataProvider<TKey, TData>: DataProviderType {
    public typealias DataType = TData
    
    private let cacheMode: CacheableDataProviderMode
    private let sourceProvider: AnyDataProvider<DataType>
    private let cacheStore: AnyStore<TKey, DataType>
    private let cacheKey: TKey
    
    public func rxData() -> Observable<DataType> {
        return Observable.empty()
    }
    
    public init<TDataProvider: DataProviderConvertibleType, TCacheStore: StoreConvertibleType
        where TDataProvider.DataType == DataType, TCacheStore.KeyType == TKey,
        TCacheStore.DataType == DataType>(sourceProvider: TDataProvider, cacheStore: TCacheStore, cacheKey: TKey, cacheMode: CacheableDataProviderMode = .CacheWithData) {
        self.sourceProvider = sourceProvider.asAnyDataProvider()
        self.cacheStore = cacheStore.asAnyStore()
        self.cacheKey = cacheKey
        self.cacheMode = cacheMode
    }
}