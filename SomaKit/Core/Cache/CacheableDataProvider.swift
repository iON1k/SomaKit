//
//  CacheableDataProvider.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public enum CacheableDataProviderMode {
    case CacheFirst
    case DataFirst(needCachePredicate: ErrorType -> Bool)
    case OnlyCache
    case NoCache
}

public class CacheState<TData> {
    public let data: TData
    public let fromCache: Bool
    
    public init(data: TData, fromCache: Bool) {
        self.data = data
        self.fromCache = fromCache
    }
}

public class CacheableDataProvider<TKey, TData>: DataProviderType {
    public typealias SourceDataType = TData
    public typealias DataType = CacheState<TData>
    
    private let cacheMode: CacheableDataProviderMode
    private let sourceProvider: AnyDataProvider<SourceDataType>
    private let cacheStore: AnyStore<TKey, SourceDataType>
    private let cacheKey: TKey
    
    public func rxData() -> Observable<DataType> {
        return Observable.deferred({ () -> Observable<DataType> in
            switch self.cacheMode {
            case .NoCache:
                return self.sourceDataProviderObservable()
            case .OnlyCache:
                return self.cacheStoreLoadDataObservable(false)
            case .CacheFirst():
                return [
                    self.cacheStoreLoadDataObservable(true)
                        .catchError({ (error) -> Observable<CacheState<TData>> in
                            return Observable.empty()
                        }),
                    self.sourceDataProviderObservable()
                ].concat()
            case .DataFirst(let needCachePredicate):
                return
                    self.sourceDataProviderObservable()
                        .catchError({ (error) -> Observable<CacheState<TData>> in
                            if needCachePredicate(error) {
                                return self.cacheStoreLoadDataObservable(true)
                                    .catchError({ (_) -> Observable<CacheState<TData>> in
                                        return Observable.error(error)
                                    })
                            } else {
                                return Observable.error(error)
                            }
                        })
            }
        })
    }
    
    public init<TDataProvider: DataProviderConvertibleType, TCacheStore: StoreConvertibleType
        where TDataProvider.DataType == SourceDataType, TCacheStore.KeyType == TKey,
        TCacheStore.DataType == SourceDataType>(sourceProvider: TDataProvider, cacheStore: TCacheStore, cacheKey: TKey,
                                          cacheMode: CacheableDataProviderMode = .CacheFirst) {
        self.sourceProvider = sourceProvider.asAnyDataProvider()
        self.cacheStore = cacheStore.asAnyStore()
        self.cacheKey = cacheKey
        self.cacheMode = cacheMode
    }
    
    private func sourceDataProviderObservable() -> Observable<DataType> {
        return sourceProvider.rxData()
            .doOnNext({ (data) in
                self.asyncSaveToCache(data)
            })
            .map({ (data) -> DataType in
                return CacheState(data: data, fromCache: false)
            })
    }
    
    private func cacheStoreLoadDataObservable(needLogErrors: Bool) -> Observable<DataType> {
        return cacheStore.loadDataAsync(self.cacheKey)
            .ignoreNil()
            .doOnError({ (error) in
                if needLogErrors {
                    Log.error("CacheableDataProvider cache loading error: \(error)")
                }
            })
            .map({ (data) -> DataType in
                return CacheState(data: data, fromCache: true)
            })
    }
    
    private func asyncSaveToCache(data: SourceDataType) {
        _ = cacheStore.saveDataAsync(cacheKey, data: data)
            .subscribe()
    }
}

public extension CacheableDataProvider {
    public func asOnlyDataProvider() -> TransformDataProvider<TData, DataType> {
        return self.transform({ (sourceObservable) -> Observable<TData> in
            return sourceObservable.map({ (cacheState) -> TData in
                return cacheState.data
            })
        })
    }
}
