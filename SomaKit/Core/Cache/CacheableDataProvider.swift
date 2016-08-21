//
//  CacheableDataProvider.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public enum CacheableDataProviderBehavior<TData> {
    public typealias CacheOnErrorPredicate = ErrorType -> Bool
    public typealias DataToCachePredicate = TData -> Bool
    
    case CacheAndData(dataToCachePredicate: DataToCachePredicate)
    case DataOrCache(cacheOnErrorPredicate: CacheOnErrorPredicate, dataToCachePredicate: DataToCachePredicate)
    case OnlyCache
    case NoCache(dataToCachePredicate: DataToCachePredicate)
}

public class CacheableDataProviderBehaviors {
    public static func cacheAndData<TData>(dataToCachePredicate: TData -> Bool = SomaFunc.truePredicate) -> CacheableDataProviderBehavior<TData> {
        return .CacheAndData(dataToCachePredicate: dataToCachePredicate)
    }
    
    public static func noCache<TData>(dataToCachePredicate: TData -> Bool = SomaFunc.truePredicate) -> CacheableDataProviderBehavior<TData> {
        return .NoCache(dataToCachePredicate: dataToCachePredicate)
    }
    
    public static func dataOrCache<TData>(cacheOnErrorPredicate: ErrorType -> Bool = SomaFunc.truePredicate,
                                   dataToCachePredicate: TData -> Bool = SomaFunc.truePredicate) -> CacheableDataProviderBehavior<TData> {
        return .DataOrCache(cacheOnErrorPredicate: cacheOnErrorPredicate, dataToCachePredicate: dataToCachePredicate)
    }
    
    public static func onlyCache<TData>() -> CacheableDataProviderBehavior<TData> {
        return .OnlyCache
    }
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
    
    private let behavior: CacheableDataProviderBehavior<SourceDataType>
    private let sourceProvider: AnyDataProvider<SourceDataType>
    private let cacheStore: AnyStore<TKey, SourceDataType>
    private let cacheKey: TKey
    private let disposeBag = DisposeBag()
    
    public func data() -> Observable<DataType> {
        return Observable.deferred({ () -> Observable<DataType> in
            switch self.behavior {
            case .NoCache(let dataToCachePredicate):
                return self.sourceDataProviderObservable(dataToCachePredicate)
            case .OnlyCache:
                return self.cacheStoreLoadDataObservable(false)
            case .CacheAndData(let dataToCachePredicate):
                return [
                    self.cacheStoreLoadDataObservable(true)
                        .catchError({ (error) -> Observable<CacheState<TData>> in
                            return Observable.empty()
                        }),
                    self.sourceDataProviderObservable(dataToCachePredicate)
                ].concat()
            case .DataOrCache(let cacheOnErrorPredicate, let dataToCachePredicate):
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
    
    public init<TDataProvider: DataProviderConvertibleType, TCacheStore: StoreConvertibleType
        where TDataProvider.DataType == SourceDataType, TCacheStore.KeyType == TKey,
        TCacheStore.DataType == SourceDataType>(sourceProvider: TDataProvider, cacheStore: TCacheStore, cacheKey: TKey, behavior: CacheableDataProviderBehavior<SourceDataType>
            = CacheableDataProviderBehaviors.dataOrCache()) {
        self.sourceProvider = sourceProvider.asAnyDataProvider()
        self.cacheStore = cacheStore.asAnyStore()
        self.cacheKey = cacheKey
        self.behavior = behavior
    }
    
    private func sourceDataProviderObservable(dataToCachePredicate: SourceDataType -> Bool) -> Observable<DataType> {
        return sourceProvider.data()
            .doOnNext({ (data) in
                if dataToCachePredicate(data) {
                    self.asyncSaveToCache(data)
                }
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
                    Log.log(error)
                }
            })
            .map({ (data) -> DataType in
                return CacheState(data: data, fromCache: true)
            })
    }
    
    private func asyncSaveToCache(data: SourceDataType) {
        cacheStore.saveDataAsync(cacheKey, data: data)
            .subscribe()
            .addDisposableTo(disposeBag)
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
