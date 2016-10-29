//
//  AbstractPagedDataProvider.swift
//  SomaKit
//
//  Created by Anton on 13.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public let PagedDataProviderDefaultPageSize = 100
private let AbstractPagedDataProviderQueueName = "AbstractPagedDataProvider_Queue"

open class AbstractPagedDataProvider<TPage: ItemsPageType>: ListDataProviderType {
    public typealias PageType = TPage
    public typealias ItemType = PageType.ItemType
    public typealias MemoryCacheType = MemoryCache<Int, PageType>
    
    private var allItemsCount: Int?
    
    private var itemsValue = [ItemType?]()
    private let itemsValueSubject = BehaviorSubject(value: [ItemType?]())
    
    private let workingScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: AbstractPagedDataProviderQueueName)
    private let stateSyncLock = SyncLock()
    
    private var loadingPagesObservables = [Int : Observable<PageType>]()
    private let loadedPagesMemoryCache: MemoryCacheType
    
    private let pageSize: Int
    
    public init(pageSize: Int, memoryCache: MemoryCacheType) {
        self.pageSize = pageSize
        loadedPagesMemoryCache = memoryCache
    }
    
    open var items: [ItemType?] {
        return stateSyncLock.sync {
            return itemsValue
        }
    }
    
    open func data() -> Observable<[ItemType?]> {
        return itemsValueSubject
    }
    
    open var isAllItemsLoaded: Bool {
        return stateSyncLock.sync {
            return allItemsCount != nil
        }
    }
    
    open func loadItem(_ index: Int) -> Observable<ItemType?> {
        return Observable.deferred { () -> Observable<ItemType?> in
            if self.validateItemIndex(index) {
                return self.unsafeLoadItem(index)
            } else {
                return Observable.just(nil)
            }
        }
        .subscribeOn(workingScheduler)
    }
    
    open func unsafeLoadItem(_ index: Int) -> Observable<ItemType?> {
        return Observable.deferred({ () -> Observable<PageType> in
            let pageIndex = self.pageForIndex(index)
            return self.createLoadingPageObservable(pageIndex)
        })
        .map({ (page) -> ItemType? in
            let pageIems = page.items
            let indexOnPage = self.indexOnPage(index)
            
            if indexOnPage < pageIems.count {
                return pageIems[indexOnPage]
            }
            
            return nil
        })
    }
    
    private func createLoadingPageObservable(_ pageIndex: Int) -> Observable<PageType> {
        if let loadedPage = loadedPagesMemoryCache.loadDataSafe(pageIndex) {
            return Observable.just(loadedPage)
        }
        
        if let loadingPage = loadingPagesObservables[pageIndex] {
            return loadingPage
        }
        
        let newPageLoadingObservable = _createLoadingPageObservable(pageIndex * pageSize, count: pageSize)
            .observeOn(workingScheduler)
            .do(onNext: { [weak self] (page) in
                self?.onPageDidLoaded(page, pageIndex: pageIndex)
            })
            .shareReplay(1)
        
        loadingPagesObservables[pageIndex] = newPageLoadingObservable
        
        return newPageLoadingObservable
    }
    
    private func onPageDidLoaded(_ page: PageType, pageIndex: Int) {
        loadingPagesObservables.removeValue(forKey: pageIndex)
        loadedPagesMemoryCache.saveDataSafe(pageIndex, data: page)
        
        guard validatePageIndex(pageIndex) else {
            return
        }
        
        let newItems = mergePage(page, pageIndex: pageIndex)
        let isLasPageType = _isLasPageType(page)
        
        stateSyncLock.sync {
            if isLasPageType {
                allItemsCount = newItems.count
            }
            
            itemsValueSubject.onNext(newItems)
        }
    }
    
    private func mergePage(_ page: PageType, pageIndex: Int) -> [ItemType?] {
        let itemsOffset = pageFirstItemIndex(pageIndex)
        let pageItems = page.items
        let isLasPageType = _isLasPageType(page)
        let newItemsCount = isLasPageType ? pageItems.count : pageSize
        
        return mergePageItems(pageItems, offset: itemsOffset, count: newItemsCount)
    }
    
    private func mergePageItems(_ newItems: [ItemType], offset: Int, count: Int) -> [ItemType?] {
        let maxIndex = offset + count
        var allItems = itemsValue
        
        while allItems.count < offset {
            allItems.append(nil)
        }
        
        var newItemIndex = 0
        for index in offset..<maxIndex {
            let newItem: ItemType? = newItemIndex < newItems.count ? newItems[newItemIndex] : nil
            
            if index < allItems.count {
                allItems[index] = newItem
            } else {
                allItems.append(newItem)
            }
            
            newItemIndex += 1
        }
        
        return allItems
    }
    
    private func pageForIndex(_ index: Int) -> Int {
        return index / pageSize
    }
    
    private func indexOnPage(_ index: Int) -> Int {
        return index % pageSize
    }
    
    private func pageFirstItemIndex(_ pageIndex: Int) -> Int {
        return pageIndex * pageSize
    }
    
    private func validateItemIndex(_ itemIndex: Int) -> Bool {
        guard let allItemsCount = allItemsCount else {
            return true
        }
        
        return itemIndex < allItemsCount
    }
    
    private func validatePageIndex(_ pageIndex: Int) -> Bool {
        let pageFirstItemIndex = pageSize * pageIndex
        return validateItemIndex(pageFirstItemIndex)
    }
    
    open func _isLasPageType(_ page: PageType) -> Bool {
        return page.items.count < pageSize
    }
    
    open func _createLoadingPageObservable(_ offset: Int, count: Int) -> Observable<PageType> {
        Utils.abstractMethod()
    }
}
