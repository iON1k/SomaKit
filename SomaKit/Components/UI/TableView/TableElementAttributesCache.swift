//
//  TableElementAttributesCache.swift
//  SomaKit
//
//  Created by Anton on 24.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol TableElementAttributesCacheSource: class {
    func tableElementAttributes(tableElementAttributesCache: TableElementAttributesCache, indexPath: NSIndexPath) -> TableElementAttributes
}

public class TableElementAttributesCache {
    private typealias CacheByIndexType = [NSIndexPath : TableElementAttributes]
    
    private var isSourceBinded = false
    private weak var source: TableElementAttributesCacheSource?
    private var attributesByIndex = CacheByIndexType()
    
    public func bindSource(source: TableElementAttributesCacheSource) {
        Utils.ensureIsMainThread()
        if isSourceBinded {
            Log.error("TableElementAttributesCache source is already binded")
            return
        }
        
        self.source = source
        isSourceBinded = true
    }
    
    public func tableElementAttributes(indexPath: NSIndexPath) -> TableElementAttributes {
        Utils.ensureIsMainThread()
        
        if let tableElementAttributes = attributesByIndex[indexPath] {
            return tableElementAttributes
        }
        
        return _reloadCache(indexPath)
    }
    
    public func invalidateCache() {
        Utils.ensureIsMainThread()
        
        attributesByIndex.removeAll()
    }
    
    public func invalidateCache(indexPath: NSIndexPath) {
        Utils.ensureIsMainThread()
        
        attributesByIndex.removeValueForKey(indexPath)
    }
    
    public func reloadCache(indexPath: NSIndexPath) {
        Utils.ensureIsMainThread()
        
        _ = _reloadCache(indexPath)
    }
    
    private func _reloadCache(indexPath: NSIndexPath) -> TableElementAttributes {
        guard let strongSource = source else {
            fatalError("TableElementAttributesCache source is nil")
        }
        
        let tableElementAttributes = strongSource.tableElementAttributes(self, indexPath: indexPath)
        attributesByIndex[indexPath] = tableElementAttributes
        
        return tableElementAttributes
    }
}
