//
//  CacheableDataProvider.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public enum CacheableDataProviderBehavior {
    case dataAfterCache
    case dataOrCache
    case cacheOnly
    case dataOnly
    
    static let `default` = dataAfterCache
}

public class CacheableDataProvider<TKey, TData>: DataProviderType {
    public typealias DataType = TData
    
    private let behavior: CacheableDataProviderBehavior
    private let dataSource: Observable<DataType>
    private let cacheStore: Store<TKey, DataType>
    private let cacheKey: TKey
    
    public func data() -> Observable<DataType> {
        return Observable.deferred({ () -> Observable<DataType> in
            switch self.behavior {
            case .dataOnly:
                return self.sourceDataProviderObservable()
            case .cacheOnly:
                return self.loadDataFromCacheObservable()
            case .dataAfterCache:
                return  Observable.concat([
                    self.loadDataFromCacheObservable(),
                    self.sourceDataProviderObservable()
                ])
            case .dataOrCache:
                return
                    self.sourceDataProviderObservable()
                        .catchError({ (error) -> Observable<DataType> in
                            return  Observable.concat([
                                self.loadDataFromCacheObservable(),
                                Observable.error(error)
                            ])
                        })
            }
        })
    }
    
    public init<TDataSource: ObservableConvertibleType, TCacheStore: StoreType>(dataSource: TDataSource,
                cacheStore: TCacheStore, cacheKey: TKey, behavior:CacheableDataProviderBehavior)
        where TDataSource.E == DataType, TCacheStore.KeyType == TKey,
        TCacheStore.DataType == DataType {
        self.dataSource = dataSource.asObservable()
        self.cacheStore = cacheStore.asStore()
        self.cacheKey = cacheKey
        self.behavior = behavior
    }
    
    private func sourceDataProviderObservable() -> Observable<DataType> {
        return dataSource
            .flatMap(self.saveDataToCacheObservable)
    }
    
    private func loadDataFromCacheObservable() -> Observable<DataType> {
        return Observable.deferred({ () -> Observable<DataType?> in
            return Observable.just(try self.cacheStore.loadData(key: self.cacheKey))
        })
        .ignoreNil()
        .logError()
        .catchErrorNoReturn()
        .subcribeOnBackgroundScheduler()
    }
    
    private func saveDataToCacheObservable(_ data: DataType) -> Observable<DataType> {
        return Observable.deferred({ () -> Observable<Void> in
            return Observable.just(try self.cacheStore.storeData(key: self.cacheKey, data: data))
        })
        .catchErrorNoReturn()
        .mapWith(data)
        .subcribeOnBackgroundScheduler()
    }
}
