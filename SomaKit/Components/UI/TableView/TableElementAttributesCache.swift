//
//  TableElementAttributesCache.swift
//  SomaKit
//
//  Created by Anton on 24.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol TableElementAttributesCacheSource {
    func tableElementAttributes(tableElementAttributesCache: TableElementAttributesCache, indexPath: NSIndexPath) -> TableElementAttributes
}

public class TableElementAttributesCache {
    private typealias CacheByIndexType = [NSIndexPath : TableElementAttributes]
    
    private let source: TableElementAttributesCacheSource
    private var attributesByIndex = CacheByIndexType()
    
    public init(source: TableElementAttributesCacheSource) {
        self.source = source
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
        let tableElementAttributes = source.tableElementAttributes(self, indexPath: indexPath)
        attributesByIndex[indexPath] = tableElementAttributes
        
        return tableElementAttributes
    }
}
