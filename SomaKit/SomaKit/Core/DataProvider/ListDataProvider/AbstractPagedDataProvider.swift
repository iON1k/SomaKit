//
//  AbstractPagedDataProvider.swift
//  SomaKit
//
//  Created by Anton on 13.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

open class AbstractPagedDataProvider<TPage: PageType>: ListDataProviderType {
    public typealias PageType = TPage
    public typealias ItemType = PageType.ItemType
    
    private var allItemsCount: Int?
    
    private let stateVariable = Variable(ListDataProviderState<ItemType>(items: [], isAllItemsLoaded: false))
    
    public let _workingScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "com.somaKit.pageDataProvider")
    
    private var loadingObservablesCache = [Int : Observable<PageType>]()
    private let pageSize: Int
    
    public init(pageSize: Int) {
        self.pageSize = pageSize
    }
    
    public func state() -> Observable<ListDataProviderState<ItemType>> {
        return stateVariable.asObservable()
    }
    
    public var currentState: ListDataProviderState<TPage.ItemType> {
        return stateVariable.value
    }
    
    public func loadItem(_ index: Int) -> Observable<ItemType?> {
        return Observable.deferred { () -> Observable<ItemType?> in
            if self.validateItemIndex(index) {
                return self.unsafeLoadItem(index)
            } else {
                return Observable.just(nil)
            }
        }
        .subscribeOn(_workingScheduler)
    }
    
    public func unsafeLoadItem(_ index: Int) -> Observable<ItemType?> {
        return Observable.deferred({ () -> Observable<PageType> in
            let pageIndex = self.pageForIndex(index)
            return self.createPageLoadingObservable(pageIndex)
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
    
    private func createPageLoadingObservable(_ pageIndex: Int) -> Observable<PageType> {
        if let loadingObservable = loadingObservablesCache[pageIndex] {
            return loadingObservable
        } else {
            let loadingObservable = _createPageLoadingObservable(pageIndex * pageSize, count: pageSize)
                .observeOn(_workingScheduler)
                .do(onNext: { (page) in
                    self.onPageDidLoaded(page, pageIndex: pageIndex)
                }, onDispose: {
                    self.loadingObservablesCache.removeValue(forKey: pageIndex)
                })
                .shareReplay(1)
            
            loadingObservablesCache[pageIndex] = loadingObservable
            
            return loadingObservable
        }
    }
    
    private func onPageDidLoaded(_ page: PageType, pageIndex: Int) {
        guard self.validatePageIndex(pageIndex) else {
            return
        }
        
        let newItems = mergePage(page, pageIndex: pageIndex)
        let isLastPage = _isLastPage(page)
        
        if isLastPage {
            allItemsCount = newItems.count
        }
        
        stateVariable <= ListDataProviderState(items: newItems, isAllItemsLoaded: isLastPage)
    }
    
    private func mergePage(_ page: PageType, pageIndex: Int) -> [ItemType?] {
        let itemsOffset = pageFirstItemIndex(pageIndex)
        let pageItems = page.items
        let isLastPage = _isLastPage(page)
        let newItemsCount = isLastPage ? pageItems.count : pageSize
        
        return mergePageItems(pageItems, offset: itemsOffset, count: newItemsCount)
    }
    
    private func mergePageItems(_ newItems: [ItemType], offset: Int, count: Int) -> [ItemType?] {
        let maxIndex = offset + count
        var allItems = stateVariable.value.items
        
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
    
    open func _isLastPage(_ page: PageType) -> Bool {
        return page.items.count < pageSize
    }
    
    open func _createPageLoadingObservable(_ offset: Int, count: Int) -> Observable<PageType> {
        Debug.abstractMethod()
    }
}
