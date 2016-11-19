//
//  AnchoredPagedDataProvider.swift
//  SomaKit
//
//  Created by Anton on 28.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

open class AnchoredPagedDataProvider<TPage: AnchoredPageType>: AbstractAnchoredPagedDataProvider<TPage> {
    public typealias AnchorType = PageType.AnchorType
    public typealias AnchoredPageObservableFactory = (_ offset: Int, _ count: Int, _ anchor: AnchorType?) -> Observable<PageType>
    
    private let anchoredPageObservableFactory: AnchoredPageObservableFactory
    
    public init(pageSize: Int, memoryCache: MemoryCacheType, anchoredPageObservableFactory: @escaping AnchoredPageObservableFactory) {
        self.anchoredPageObservableFactory = anchoredPageObservableFactory
        super.init(pageSize: pageSize, memoryCache: memoryCache)
    }
    
    public convenience init(pageSize: Int = PagedDataProviderDefaultPageSize, anchoredPageObservableFactory: @escaping AnchoredPageObservableFactory) {
        self.init(pageSize: pageSize, memoryCache: MemoryCacheType(), anchoredPageObservableFactory: anchoredPageObservableFactory)
    }
    
    open override func _createAnchoredPageLoadingObservable(_ offset: Int, count: Int, anchoredPage: PageType?) -> Observable<PageType> {
        return anchoredPageObservableFactory(offset, count, anchoredPage?.anchor)
    }
}

extension AnchoredPagedDataProvider {
    public convenience init<TDataSource: ObservableConvertibleType, TCacheStore: StoreType>(pageSize: Int = PagedDataProviderDefaultPageSize,
                                                                                            cacheStore: TCacheStore,
                                                                                            cacheBehavior: CacheableDataProviderBehavior = .default,
                                                                                            dataSourceFactory: @escaping (_ offset: Int, _ count: Int, _ anchor: AnchorType?) -> TDataSource)
        where TDataSource: CachingKeyProvider, TCacheStore.KeyType == TDataSource.CachingKeyType,
        TCacheStore.DataType == TDataSource.E, TDataSource.E == PageType {
        self.init(pageSize: pageSize, memoryCache: MemoryCacheType()) { (offset, count, anchor) -> Observable<PageType> in
            return dataSourceFactory(offset, count, anchor)
                .asCacheableProvider(cacheStore, behavior: cacheBehavior)
                .data()
        }
    }
}
