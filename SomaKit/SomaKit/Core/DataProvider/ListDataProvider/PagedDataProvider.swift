//
//  PagedDataProvider.swift
//  SomaKit
//
//  Created by Anton on 28.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

open class PagedDataProvider<TPage: PageType>: AbstractPagedDataProvider<TPage> {
    public typealias PageObservableFactory = (_ offset: Int, _ count: Int) -> Observable<PageType>
    
    private let pageObservableFactory: PageObservableFactory
    
    public init(pageSize: Int = PagedDataProviderConstants.DefaultPageSize, pageObservableFactory: @escaping PageObservableFactory) {
        self.pageObservableFactory = pageObservableFactory
        super.init(pageSize: pageSize)
    }
    
    open override func _createPageLoadingObservable(_ offset: Int, count: Int) -> Observable<PageType> {
        return pageObservableFactory(offset, count)
    }
}

extension PagedDataProvider {
    public convenience init<TDataSource: ObservableConvertibleType, TCacheStore: StoreType>(pageSize: Int = PagedDataProviderConstants.DefaultPageSize,
                                    cacheStore: TCacheStore, cacheBehavior: CacheableDataProviderBehavior = .default,
                                    dataSourceFactory: @escaping (_ offset: Int, _ count: Int) -> TDataSource)
        where TDataSource: CachingKeyProvider, TCacheStore.KeyType == TDataSource.CachingKeyType,
        TCacheStore.DataType == TDataSource.E, TDataSource.E == PageType {
        self.init(pageSize: pageSize) { (offset, count) -> Observable<PageType> in
            return dataSourceFactory(offset, count)
                .asCacheableProvider(cacheStore, behavior: cacheBehavior)
                .data()
        }
    }
}
