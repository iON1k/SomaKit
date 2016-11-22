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

open class AbstractPagedDataProvider<TPage: PageType>: ListDataProviderType {
    public typealias PageType = TPage
    public typealias ItemType = PageType.ItemType
    
    private var allItemsCount: Int?
    
    private var itemsValue = [ItemType?]()
    private let itemsValueSubject = BehaviorSubject(value: [ItemType?]())
    
    public let _workingScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: AbstractPagedDataProviderQueueName)
    private let stateSyncLock = SyncLock()
    
    private let pageSize: Int
    
    public init(pageSize: Int) {
        self.pageSize = pageSize
    }
    
    public var items: [ItemType?] {
        return stateSyncLock.sync {
            return itemsValue
        }
    }
    
    public func data() -> Observable<[ItemType?]> {
        return itemsValueSubject
    }
    
    public var isAllItemsLoaded: Bool {
        return stateSyncLock.sync {
            return allItemsCount != nil
        }
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
        return _createPageLoadingObservable(pageIndex * pageSize, count: pageSize)
            .observeOn(_workingScheduler)
            .do(onNext: { (page) in
                self.onPageDidLoaded(page, pageIndex: pageIndex)
            })
    }
    
    private func onPageDidLoaded(_ page: PageType, pageIndex: Int) {
        guard self.validatePageIndex(pageIndex) else {
            return
        }
        
        let newItems = mergePage(page, pageIndex: pageIndex)
        let isLasPageType = _isLasPageType(page)
        
        self.stateSyncLock.sync {
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
    
    open func _createPageLoadingObservable(_ offset: Int, count: Int) -> Observable<PageType> {
        Debug.abstractMethod()
    }
}
