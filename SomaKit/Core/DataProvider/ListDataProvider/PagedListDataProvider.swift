//
//  PagedListDataProvider.swift
//  SomaKit
//
//  Created by Anton on 13.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

private let PagedListDataProviderQueueName = "PagedListDataProvider_Queue"
private let PagedListDataProviderDefaultPageSize = 20

public class PagedListDataProvider<TItem, TPage: ItemsPageType where TPage.ItemType == TItem>: ListDataProviderType {
    public typealias ItemType = TItem
    public typealias ItemsMergeResult = (items: [TItem?], hasChanges: Bool)
    
    private var lastPageIndex: Int?
    
    private var itemsValue = [TItem?]()
    private let itemsValueSubject = BehaviorSubject(value: [TItem?]())
    
    private let workingScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: PagedListDataProviderQueueName)
    private let stateSyncLock = SyncLock()
    
    private var loadingPagesObservables = [Int : Observable<TPage>]()
    private let loadedPagesMemoryCache: MemoryCache<Int, TPage>
    
    private let pageSize: Int
    
    public init(pageSize: Int = PagedListDataProviderDefaultPageSize, cacheLifeTimeType: CacheLifeTimeType = .Forever) {
        self.pageSize = pageSize
        loadedPagesMemoryCache = MemoryCache<Int, TPage>(lifeTimeType: cacheLifeTimeType)
    }
    
    public var items: [TItem?] {
        return stateSyncLock.sync {
            return itemsValue
        }
    }
    
    public func data() -> Observable<[ItemType?]> {
        return itemsValueSubject
    }
    
    public var isAllItemsLoaded: Bool {
        return stateSyncLock.sync {
            return lastPageIndex != nil
        }
    }
    
    public func loadItem(index: Int) -> Observable<ItemType?> {
        return Observable.deferred { () -> Observable<ItemType?> in
            let pageIndex = self.pageForIndex(index)
            
            if self.validatePageIndex(pageIndex) {
                return self.unsafeLoadItem(index)
            } else {
                return Observable.just(nil)
            }
        }
        .subscribeOn(workingScheduler)
    }
    
    public func unsafeLoadItem(index: Int) -> Observable<ItemType?> {
        return Observable.deferred({ () -> Observable<TPage> in
            let pageIndex = self.pageForIndex(index)
            return self.createLoadingPageObservable(pageIndex)
        })
            .map({ (page) -> TItem? in
                let pageIems = page.items
                let indexOnPage = self.indexOnPage(index)
                
                if indexOnPage < pageIems.count {
                    return pageIems[indexOnPage]
                }
                
                return nil
                
            })
    }
    
    private func createLoadingPageObservable(pageIndex: Int) -> Observable<TPage> {
        if let loadedPage = loadedPagesMemoryCache.loadDataSafe(pageIndex) {
            return Observable.just(loadedPage)
        }
        
        if let loadingPage = loadingPagesObservables[pageIndex] {
            return loadingPage
        }
        
        let newPageLoadingObservable = _createLoadingPageObservable(pageIndex * pageSize, count: pageSize)
            .observeOn(workingScheduler)
            .doOnNext({ [weak self] (page) in
                self?.onPageDidLoaded(page, pageIndex: pageIndex)
            })
        
        loadingPagesObservables[pageIndex] = newPageLoadingObservable
        
        return newPageLoadingObservable
    }
    
    private func onPageDidLoaded(page: TPage, pageIndex: Int) {
        loadingPagesObservables.removeValueForKey(pageIndex)
        loadedPagesMemoryCache.saveDataSafe(pageIndex, data: page)
        
        if !validatePageIndex(pageIndex) {
            return
        }
        
        let mergeResult = mergePage(page, pageIndex: pageIndex)
        let hasChanges = mergeResult.hasChanges
        let isLastPage = page.isLastPage
        
        stateSyncLock.sync {
            if hasChanges  {
                itemsValue = mergeResult.items
            }
            
            if isLastPage {
                lastPageIndex = pageIndex
            }
        }
        
        if hasChanges {
            itemsValueSubject.onNext(itemsValue)
        }
    }
    
    private func mergePage(page: TPage, pageIndex: Int) -> ItemsMergeResult {
        let itemsOffset = pageIndex * pageSize
        let pageItems = page.items
        let isLastPage = page.isLastPage
        let newItemsCount = isLastPage ? pageItems.count : pageSize
        
        let mergeResult = mergePageItems(pageItems, offset: itemsOffset, count: newItemsCount)
        
        var newItemsValue = mergeResult.items
        var hasChanges = mergeResult.hasChanges
        
        if isLastPage {
            let newItemsCount = itemsOffset + newItemsCount
            if newItemsValue.count > newItemsCount {
                newItemsValue = Array(newItemsValue[0..<newItemsCount])
                hasChanges = true
            }
        }
        
        return ItemsMergeResult(newItemsValue, hasChanges)
    }
    
    private func mergePageItems(newItems: [TItem], offset: Int, count: Int) -> ItemsMergeResult {
        let maxIndex = offset + count
        
        if maxIndex < itemsValue.count {
            let subItems = Array(itemsValue[offset..<count])
            if subItems.isEquivalent(newItems) {
                return ItemsMergeResult(itemsValue, false)
            }
        }
        
        var allItems = itemsValue
        
        while allItems.count < offset {
            allItems.append(nil)
        }
        
        var newItemIndex = 0
        for index in offset..<maxIndex {
            let newItem: TItem? = newItemIndex < newItems.count ? newItems[newItemIndex] : nil
            
            if index < allItems.count {
                allItems[index] = newItem
            } else {
                allItems.append(newItem)
            }
            
            newItemIndex += 1
        }
        
        return ItemsMergeResult(allItems, true)
    }
    
    private func pageForIndex(index: Int) -> Int {
        return index / pageSize
    }
    
    private func indexOnPage(index: Int) -> Int {
        return index % pageSize
    }
    
    private func validatePageIndex(pageIndex: Int) -> Bool {
        guard let lastPageIndex = lastPageIndex else {
            return true
        }
        
        return pageIndex <= lastPageIndex
    }
    
    public func _createLoadingPageObservable(offset: Int, count: Int) -> Observable<TPage> {
        Utils.abstractMethod()
    }
}