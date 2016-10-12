//
//  CacheableDataProvider.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public enum CacheableDataProviderBehavior<TData> {
    public typealias CacheOnErrorPredicate = (Error) -> Bool
    public typealias DataToCachePredicate = (TData) -> Bool
    
    case cacheAndData(dataToCachePredicate: DataToCachePredicate)
    case dataOrCache(cacheOnErrorPredicate: CacheOnErrorPredicate, dataToCachePredicate: DataToCachePredicate)
    case onlyCache
    case onlyData(dataToCachePredicate: DataToCachePredicate)
}

open class CacheableDataProviderBehaviors {
    open static func cacheAndData<TData>(_ dataToCachePredicate: @escaping (TData) -> Bool = SomaFunc.truePredicate) -> CacheableDataProviderBehavior<TData> {
        return .cacheAndData(dataToCachePredicate: dataToCachePredicate)
    }
    
    open static func noCache<TData>(_ dataToCachePredicate: @escaping (TData) -> Bool = SomaFunc.truePredicate) -> CacheableDataProviderBehavior<TData> {
        return .onlyData(dataToCachePredicate: dataToCachePredicate)
    }
    
    open static func dataOrCache<TData>(_ cacheOnErrorPredicate: @escaping (Error) -> Bool = SomaFunc.truePredicate,
                                   dataToCachePredicate: @escaping (TData) -> Bool = SomaFunc.truePredicate) -> CacheableDataProviderBehavior<TData> {
        return .dataOrCache(cacheOnErrorPredicate: cacheOnErrorPredicate, dataToCachePredicate: dataToCachePredicate)
    }
    
    open static func onlyCache<TData>() -> CacheableDataProviderBehavior<TData> {
        return .onlyCache
    }
}

public protocol CacheStateType {
    associatedtype DataType
    var data: DataType { get }
    var fromCache: Bool { get }
}

open class CacheState<TData>: CacheStateType {
    public typealias DataType = TData
    
    open let data: DataType
    open let fromCache: Bool
    
    public init(data: DataType, fromCache: Bool) {
        self.data = data
        self.fromCache = fromCache
    }
}

open class CacheableDataProvider<TKey, TData>: DataProviderType {
    public typealias SourceDataType = TData
    public typealias DataType = CacheState<TData>
    
    fileprivate let behavior: CacheableDataProviderBehavior<SourceDataType>
    fileprivate let dataSource: Observable<SourceDataType>
    fileprivate let cacheStore: AnyStore<TKey, SourceDataType>
    fileprivate let cacheKey: TKey
    fileprivate let disposeBag = DisposeBag()
    
    open func data() -> Observable<DataType> {
        return Observable.deferred({ () -> Observable<DataType> in
            switch self.behavior {
            case .onlyData(let dataToCachePredicate):
                return self.sourceDataProviderObservable(dataToCachePredicate)
            case .onlyCache:
                return self.cacheStoreLoadDataObservable(false)
            case .cacheAndData(let dataToCachePredicate):
                return [
                    self.cacheStoreLoadDataObservable(true)
                        .catchError({ (error) -> Observable<CacheState<TData>> in
                            return Observable.empty()
                        }),
                    self.sourceDataProviderObservable(dataToCachePredicate)
                ].concat()
            case .dataOrCache(let cacheOnErrorPredicate, let dataToCachePredicate):
                return
                    self.sourceDataProviderObservable(dataToCachePredicate)
                        .catchError({ (error) -> Observable<CacheState<TData>> in
                            if cacheOnErrorPredicate(error) {
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
    
    public init<TDataSource: ObservableConvertibleType, TCacheStore: StoreConvertibleType>(dataSource: TDataSource, cacheStore: TCacheStore, cacheKey: TKey, behavior: CacheableDataProviderBehavior<SourceDataType>
            = CacheableDataProviderBehaviors.dataOrCache())
        where TDataSource.E == SourceDataType, TCacheStore.KeyType == TKey,
        TCacheStore.DataType == SourceDataType {
        self.dataSource = dataSource.asObservable()
        self.cacheStore = cacheStore.asStore()
        self.cacheKey = cacheKey
        self.behavior = behavior
    }
    
    fileprivate func sourceDataProviderObservable(_ dataToCachePredicate: @escaping (SourceDataType) -> Bool) -> Observable<DataType> {
        return dataSource
            .do(onNext: { (data) in
                if dataToCachePredicate(data) {
                    self.asyncSaveToCache(data)
                }
            })
            .map({ (data) -> DataType in
                return CacheState(data: data, fromCache: false)
            })
    }
    
    fileprivate func cacheStoreLoadDataObservable(_ needLogErrors: Bool) -> Observable<DataType> {
        return cacheStore.loadDataAsync(self.cacheKey)
            .ignoreNil()
            .do(onError: { (error) in
                if needLogErrors {
                    Log.log(error)
                }
            })
            .map({ (data) -> DataType in
                return CacheState(data: data, fromCache: true)
            })
    }
    
    fileprivate func asyncSaveToCache(_ data: SourceDataType) {
        cacheStore.saveDataAsync(cacheKey, data: data)
            .subscribe()
            .addDisposableTo(disposeBag)
    }
}

extension Observable where Element: CacheStateType {
    public func onlyData() -> Observable<E.DataType> {
        return map({ (cacheState) in
            return cacheState.data
        })
    }
}
