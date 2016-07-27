//
//  CellAttributesCache.swift
//  SomaKit
//
//  Created by Anton on 24.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol CellAttributesCacheSource {
    func cellAttributes(cellAttributesCache: CellAttributesCache, indexPath: NSIndexPath) -> CellAttributesType
}

public class CellAttributesCache {
    private typealias CacheByIndexType = [NSIndexPath : CellAttributesType]
    
    private let source: CellAttributesCacheSource
    private var attributesByIndex = CacheByIndexType()
    
    public init(source: CellAttributesCacheSource) {
        self.source = source
    }
    
    public func cellAttributes(indexPath: NSIndexPath) -> CellAttributesType {
        Utils.ensureIsMainThread()
        
        if let cellAttributes = attributesByIndex[indexPath] {
            return cellAttributes
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
    
    private func _reloadCache(indexPath: NSIndexPath) -> CellAttributesType {
        let cellAttributes = source.cellAttributes(self, indexPath: indexPath)
        attributesByIndex[indexPath] = cellAttributes
        
        return cellAttributes
    }
}
