//
//  CellAttributesCache.swift
//  SomaKit
//
//  Created by Anton on 24.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol CellAttributesCacheDelegate {
    func sectionsCount(cellAttributesCache: CellAttributesCache) -> Int
    func rowsCount(cellAttributesCache: CellAttributesCache, sectionNumber: Int) -> Int
    func cellAttributes(cellAttributesCache: CellAttributesCache, indexPath: NSIndexPath) -> CellAttributesType
}

public class CellAttributesCache {
    private typealias CacheByIndexType = [NSIndexPath : CellAttributesType]
    
    private let delegate: CellAttributesCacheDelegate
    private var attributesByIndex = CacheByIndexType()
    
    public init(delegate: CellAttributesCacheDelegate) {
        self.delegate = delegate
    }
    
    public func cellAttributes(indexPath: NSIndexPath) -> CellAttributesType {
        Utils.ensureMainThread()
        
        if let cellAttributes = attributesByIndex[indexPath] {
            return cellAttributes
        }
        
        return _reloadCache(indexPath)
    }
    
    public func invalidateCache() {
        Utils.ensureMainThread()
        
        attributesByIndex.removeAll()
    }
    
    public func invalidateCache(indexPath: NSIndexPath) {
        Utils.ensureMainThread()
        
        attributesByIndex.removeValueForKey(indexPath)
    }
    
    public func reloadCache(indexPath: NSIndexPath) {
        Utils.ensureMainThread()
        
        _ = _reloadCache(indexPath)
    }
    
    public func reloadCache() -> Void {
        Utils.ensureMainThread()
        
        attributesByIndex = _loadAllCellsAttributes()
    }
    
    public func reloadCacheAsync(indexPath: NSIndexPath) -> Observable<Void> {
        return Observable.deferred({ () -> Observable<CellAttributesType> in
            return Observable.just(self.delegate.cellAttributes(self, indexPath: indexPath))
                .subcribeOnBackgroundScheduler()
            })
            .observeOn(MainScheduler.instance)
            .doOnNext({ (cellAttributes) in
                self.attributesByIndex[indexPath] = cellAttributes
            })
            .map(SomaFunc.emptyFunc)
    }
    
    public func reloadCacheAsync() -> Observable<Void> {
        return Observable.deferred({ () -> Observable<CacheByIndexType> in
            return Observable.just(self._loadAllCellsAttributes())
                .subcribeOnBackgroundScheduler()
        })
            .observeOn(MainScheduler.instance)
            .doOnNext({ (attributesByIndex) in
                self.attributesByIndex = attributesByIndex
            })
            .map(SomaFunc.emptyFunc)
    }
    
    private func _reloadCache(indexPath: NSIndexPath) -> CellAttributesType {
        let cellAttributes = delegate.cellAttributes(self, indexPath: indexPath)
        attributesByIndex[indexPath] = cellAttributes
        
        return cellAttributes
    }
    
    private func _loadAllCellsAttributes() -> CacheByIndexType {
        var newAttributesByIndex = CacheByIndexType()
        
        for section in 0..<delegate.sectionsCount(self) {
            for row in 0..<delegate.rowsCount(self, sectionNumber: section) {
                let indexPath = NSIndexPath(forRow: row, inSection: section)
                newAttributesByIndex[indexPath] = delegate.cellAttributes(self, indexPath: indexPath)
            }
        }
        
        return newAttributesByIndex
    }
}
