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
    case OnlyData(dataToCachePredicate: DataToCachePredicate)
}

public class CacheableDataProviderBehaviors {
    public static func cacheAndData<TData>(dataToCachePredicate: TData -> Bool = SomaFunc.truePredicate) -> CacheableDataProviderBehavior<TData> {
        return .CacheAndData(dataToCachePredicate: dataToCachePredicate)
    }
    
    public static func noCache<TData>(dataToCachePredicate: TData -> Bool = SomaFunc.truePredicate) -> CacheableDataProviderBehavior<TData> {
        return .OnlyData(dataToCachePredicate: dataToCachePredicate)
    }
    
    public static func dataOrCache<TData>(cacheOnErrorPredicate: ErrorType -> Bool = SomaFunc.truePredicate,
                                   dataToCachePredicate: TData -> Bool = SomaFunc.truePredicate) -> CacheableDataProviderBehavior<TData> {
        return .DataOrCache(cacheOnErrorPredicate: cacheOnErrorPredicate, dataToCachePredicate: dataToCachePredicate)
    }
    
    public static func onlyCache<TData>() -> CacheableDataProviderBehavior<TData> {
        return .OnlyCache
    }
}

public protocol CacheStateType {
    associatedtype DataType
    var data: DataType { get }
    var fromCache: Bool { get }
}

public class CacheState<TData>: CacheStateType {
    public typealias DataType = TData
    
    public let data: DataType
    public let fromCache: Bool
    
    public init(data: DataType, fromCache: Bool) {
        self.data = data
        self.fromCache = fromCache
    }
}

public class CacheableDataProvider<TKey, TData>: DataProviderType {
    public typealias SourceDataType = TData
    public typealias DataType = CacheState<TData>
    
    private let behavior: CacheableDataProviderBehavior<SourceDataType>
    private let dataSource: Observable<SourceDataType>
    private let cacheStore: AnyStore<TKey, SourceDataType>
    private let cacheKey: TKey
    private let disposeBag = DisposeBag()
    
    public func data() -> Observable<DataType> {
        return Observable.deferred({ () -> Observable<DataType> in
            switch self.behavior {
            case .OnlyData(let dataToCachePredicate):
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
    
    public init<TDataSource: ObservableConvertibleType, TCacheStore: StoreConvertibleType
        where TDataSource.E == SourceDataType, TCacheStore.KeyType == TKey,
        TCacheStore.DataType == SourceDataType>(dataSource: TDataSource, cacheStore: TCacheStore, cacheKey: TKey, behavior: CacheableDataProviderBehavior<SourceDataType>
            = CacheableDataProviderBehaviors.dataOrCache()) {
        self.dataSource = dataSource.asObservable()
        self.cacheStore = cacheStore.asStore()
        self.cacheKey = cacheKey
        self.behavior = behavior
    }
    
    private func sourceDataProviderObservable(dataToCachePredicate: SourceDataType -> Bool) -> Observable<DataType> {
        return dataSource
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

extension Observable where Element: CacheStateType {
    public func onlyData() -> Observable<E.DataType> {
        return map({ (cacheState) in
            return cacheState.data
        })
    }
}
