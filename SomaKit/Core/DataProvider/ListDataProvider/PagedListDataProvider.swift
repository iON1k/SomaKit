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
    
    private var isAllItemsLoadedValue = false
    private let isAllItemsLoadedSubject = BehaviorSubject(value: false)
    
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
    
    public func dataObservable() -> Observable<[ItemType?]> {
        return itemsValueSubject
    }
    
    public var isAllItemsLoaded: Bool {
        return stateSyncLock.sync {
            return isAllItemsLoadedValue
        }
    }
    
    public var isAllItemsLoadedObservable: Observable<Bool> {
        return isAllItemsLoadedSubject
            .distinctUntilChanged()
    }
    
    public func loadItem(index: Int) -> Observable<ItemType?> {
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
        .subscribeOn(workingScheduler)
    }
    
    private func createLoadingPageObservable(pageIndex: Int) -> Observable<TPage> {
        if let loadedPage = loadedPagesMemoryCache.loadDataSafe(pageIndex) {
            return Observable.just(loadedPage)
        }
        
        if let loadingPage = loadingPagesObservables[pageIndex] {
            return loadingPage
        }
        
        let newPageLoadingObservable = _createLoadingPage(pageIndex * pageSize, count: pageSize)
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
        let newItemsValue = mergedItems(page.items, offset: pageIndex * pageSize, count: pageSize)
        
        stateSyncLock.sync {
            if let newItemsValue = newItemsValue {
                itemsValue = newItemsValue
            }
            
            isAllItemsLoadedValue = page.isLastPage
        }
        
        if newItemsValue != nil {
            itemsValueSubject.onNext(itemsValue)
        }
        
        isAllItemsLoadedSubject.onNext(isAllItemsLoadedValue)
    }
    
    //nil, if no changes
    private func mergedItems(newItems: [TItem], offset: Int, count: Int) -> [TItem?]? {
        let maxIndex = offset + count
        
        if maxIndex < itemsValue.count {
            let subItems = Array(itemsValue[offset..<count])
            if subItems.isEquivalent(newItems) {
                return nil
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
        
        return itemsValue
    }
    
    private func pageForIndex(index: Int) -> Int {
        return index / pageSize
    }
    
    private func indexOnPage(index: Int) -> Int {
        return index % pageSize
    }
    
    public func _createLoadingPage(offset: Int, count: Int) -> Observable<TPage> {
        Utils.abstractMethod()
    }
}