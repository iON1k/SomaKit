//
//  PagedDataProvider.swift
//  SomaKit
//
//  Created by Anton on 28.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

open class PagedDataProvider<TPage: ItemsPageType>: AbstractPagedDataProvider<TPage> {
    public typealias PageObservableFactory = (_ offset: Int, _ count: Int) -> Observable<PageType>
    
    fileprivate let pageObservableFactory: PageObservableFactory
    
    public init(pageSize: Int, memoryCache: MemoryCacheType, pageObservableFactory: @escaping PageObservableFactory) {
        self.pageObservableFactory = pageObservableFactory
        super.init(pageSize: pageSize, memoryCache: memoryCache)
    }
    
    public convenience init(pageSize: Int = PagedDataProviderDefaultPageSize, pageObservableFactory: @escaping PageObservableFactory) {
        self.init(pageSize: pageSize, memoryCache: MemoryCacheType(), pageObservableFactory: pageObservableFactory)
    }
    
    open override func _createLoadingPageObservable(_ offset: Int, count: Int) -> Observable<PageType> {
        return pageObservableFactory(offset, count)
    }
}

extension PagedDataProvider {
    public convenience init<TDataSource: ObservableConvertibleType, TCacheStore: StoreConvertibleType>(pageSize: Int = PagedDataProviderDefaultPageSize,
                                    cacheStore: TCacheStore, cacheBehavior: CacheableDataProviderBehavior<PageType> = CacheableDataProviderBehaviors.cacheAndData(),
                                    dataSourceFactory: @escaping (_ offset: Int, _ count: Int) -> TDataSource)
        where TDataSource: CachingKeyProvider, TCacheStore.KeyType == TDataSource.CachingKeyType,
        TCacheStore.DataType == TDataSource.E, TDataSource.E == PageType {
        self.init(pageSize: pageSize, memoryCache: MemoryCacheType()) { (offset, count) -> Observable<PageType> in
            return dataSourceFactory(offset, count)
                .asCacheableProvider(cacheStore, behavior: cacheBehavior)
                .data()
                .onlyData()
        }
    }
}
