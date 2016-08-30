//
//  PagedDataProvider.swift
//  SomaKit
//
//  Created by Anton on 28.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class PagedDataProvider<TPage: ItemsPageType>: AbstractPagedDataProvider<TPage> {
    public typealias PageObservableFactory = (offset: Int, count: Int) -> Observable<PageType>
    
    private let pageObservableFactory: PageObservableFactory
    
    public init(pageSize: Int, memoryCache: MemoryCacheType, pageObservableFactory: PageObservableFactory) {
        self.pageObservableFactory = pageObservableFactory
        super.init(pageSize: pageSize, memoryCache: memoryCache)
    }
    
    public convenience init(pageSize: Int = PagedDataProviderDefaultPageSize, pageObservableFactory: PageObservableFactory) {
        self.init(pageSize: pageSize, memoryCache: MemoryCacheType(), pageObservableFactory: pageObservableFactory)
    }
    
    public override func _createLoadingPageObservable(offset: Int, count: Int) -> Observable<PageType> {
        return pageObservableFactory(offset: offset, count: count)
    }
}

extension PagedDataProvider {
    public convenience init<TDataSource: ObservableConvertibleType, TCacheStore: StoreConvertibleType
        where TDataSource: CachingKeyProvider, TCacheStore.KeyType == TDataSource.CachingKeyType,
        TCacheStore.DataType == TDataSource.E, TDataSource.E == PageType>(pageSize: Int = PagedDataProviderDefaultPageSize,
                                    cacheStore: TCacheStore, cacheBehavior: CacheableDataProviderBehavior<PageType> = CacheableDataProviderBehaviors.cacheAndData(),
                                    dataSourceFactory: (offset: Int, count: Int) -> TDataSource) {
        self.init(pageSize: pageSize, memoryCache: MemoryCacheType()) { (offset, count) -> Observable<PageType> in
            return dataSourceFactory(offset: offset, count: count)
                .asCacheableProvider(cacheStore, behavior: cacheBehavior)
                .data()
                .onlyData()
        }
    }
}
