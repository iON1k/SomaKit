//
//  AnchoredPagedDataProvider.swift
//  SomaKit
//
//  Created by Anton on 28.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class AnchoredPagedDataProvider<TPage: AnchoredPageType>: AbstractAnchoredPagedDataProvider<TPage> {
    public typealias AnchorType = PageType.AnchorType
    public typealias AnchoredPageObservableFactory = (offset: Int, count: Int, anchor: AnchorType?) -> Observable<PageType>
    
    private let anchoredPageObservableFactory: AnchoredPageObservableFactory
    
    public init(pageSize: Int, memoryCache: MemoryCacheType, anchoredPageObservableFactory: AnchoredPageObservableFactory) {
        self.anchoredPageObservableFactory = anchoredPageObservableFactory
        super.init(pageSize: pageSize, memoryCache: memoryCache)
    }
    
    public convenience init(pageSize: Int = PagedDataProviderDefaultPageSize, anchoredPageObservableFactory: AnchoredPageObservableFactory) {
        self.init(pageSize: pageSize, memoryCache: MemoryCacheType(), anchoredPageObservableFactory: anchoredPageObservableFactory)
    }
    
    public override func _createLoadingAnchoredPageObservable(offset: Int, count: Int, anchoredPage: PageType?) -> Observable<PageType> {
        return anchoredPageObservableFactory(offset: offset, count: count, anchor: anchoredPage?.anchor)
    }
}

extension AnchoredPagedDataProvider {
    public convenience init<TDataProvider: DataProviderConvertibleType, TCacheStore: StoreConvertibleType
        where TDataProvider: CachingKeyProvider, TCacheStore.KeyType == TDataProvider.CachingKeyType,
        TCacheStore.DataType == TDataProvider.DataType, TDataProvider.DataType == PageType>(pageSize: Int = PagedDataProviderDefaultPageSize,
                                                                                            cacheStore: TCacheStore, cacheBehavior: CacheableDataProviderBehavior<PageType> = CacheableDataProviderBehaviors.cacheAndData(),
                                                                                            pageObservableFactory: (offset: Int, count: Int, anchor: AnchorType?) -> TDataProvider) {
        self.init(pageSize: pageSize, memoryCache: MemoryCacheType()) { (offset, count, anchor) -> Observable<PageType> in
            return pageObservableFactory(offset: offset, count: count, anchor: anchor)
                .asCacheableProvider(cacheStore, behavior: cacheBehavior)
                .dataOnly()
                .asObservable()
        }
    }
}