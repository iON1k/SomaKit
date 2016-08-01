//
//  TableElementAttributesCache.swift
//  SomaKit
//
//  Created by Anton on 24.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol TableElementAttributesCacheSource: class {
    func sectionHeaderAttributes(tableElementAttributesCache: TableElementAttributesCache, sectionIndex: Int) -> TableElementAttributes
    func sectionFooterAttributes(tableElementAttributesCache: TableElementAttributesCache, sectionIndex: Int) -> TableElementAttributes
    func cellAttributes(tableElementAttributesCache: TableElementAttributesCache, indexPath: NSIndexPath) -> TableElementAttributes
}

public class TableElementAttributesCache {
    private typealias SectionsAttributesByIndexType = [Int : MutableTableSectionElementsAttributes]
    public weak var source: TableElementAttributesCacheSource?
    
    private var _sectionAttributesByIndex = SectionsAttributesByIndexType()
    
    public func cellAttributes(indexPath: NSIndexPath) -> TableElementAttributes {
        Utils.ensureIsMainThread()
        
        let sectionAttributes = sectionAttributesByIndex(indexPath.section)
        if let cellAttributes = sectionAttributes.cellsAttributes[indexPath.row] {
            return cellAttributes
        }
        
        return _reloadCellAttributes(indexPath)
    }
    
    public func sectionHeaderAttributes(sectionIndex: Int) -> TableElementAttributes {
        Utils.ensureIsMainThread()
        
        let sectionAttributes = sectionAttributesByIndex(sectionIndex)
        if let sectionHeaderAttributes = sectionAttributes.headerAttributes {
            return sectionHeaderAttributes
        }
        
        return _reloadSectionHeaderAttributes(sectionIndex)
    }
    
    public func sectionFooterAttributes(sectionIndex: Int) -> TableElementAttributes {
        Utils.ensureIsMainThread()
        
        let sectionAttributes = sectionAttributesByIndex(sectionIndex)
        if let sectionFooterAttributes = sectionAttributes.footerAttributes {
            return sectionFooterAttributes
        }
        
        return _reloadSectionFooterAttributes(sectionIndex)
    }
    
    public func sectionAttributes(sectionIndex: Int) -> TableSectionElementsAttributes {
        Utils.ensureIsMainThread()
        
        return sectionAttributesByIndex(sectionIndex).copy()
    }
    
    public func resetCacheWithPreloadedData(preloadedData: [TableSectionElementsAttributes]) {
        invalidateCache()
        
        for (index, sectionData) in preloadedData.enumerate() {
            _sectionAttributesByIndex[index] = sectionData.mutableCopy()
        }
    }
    
    public func invalidateCache() {
        Utils.ensureIsMainThread()
        
        _sectionAttributesByIndex.removeAll()
    }
    
    public func invalidateSectionCache(sectionIndex: Int) {
        Utils.ensureIsMainThread()
        
        _sectionAttributesByIndex.removeValueForKey(sectionIndex)
    }
    
    public func invalidateCellCache(indexPath: NSIndexPath) {
        Utils.ensureIsMainThread()
        
        var sectionAttributes = sectionAttributesByIndex(indexPath.section)
        sectionAttributes.cellsAttributes.removeValueForKey(indexPath.row)
    }
    
    public func invalidateSectionHeaderCache(sectionIndex: Int) {
        Utils.ensureIsMainThread()
        
        var sectionAttributes = sectionAttributesByIndex(sectionIndex)
        sectionAttributes.headerAttributes = nil
    }
    
    public func invalidateSectionFooterCache(sectionIndex: Int) {
        Utils.ensureIsMainThread()
        
        var sectionAttributes = sectionAttributesByIndex(sectionIndex)
        sectionAttributes.footerAttributes = nil
    }
    
    public func reloadCellAttributes(indexPath: NSIndexPath) {
        Utils.ensureIsMainThread()
        
        _ = _reloadCellAttributes(indexPath)
    }
    
    public func reloadSectionHeaderAttributes(sectionIndex: Int) {
        Utils.ensureIsMainThread()
        
        _ = _reloadSectionHeaderAttributes(sectionIndex)
    }
    
    public func reloadSectionFooterAttributes(sectionIndex: Int) {
        Utils.ensureIsMainThread()
        
        _ = _reloadSectionFooterAttributes(sectionIndex)
    }
    
    private func _reloadCellAttributes(indexPath: NSIndexPath) -> TableElementAttributes {
        let cellAttributes = strongSource().cellAttributes(self, indexPath: indexPath)
        var sectionAttributes = sectionAttributesByIndex(indexPath.section)
        sectionAttributes.cellsAttributes[indexPath.row] = cellAttributes
        
        return cellAttributes
    }
    
    private func _reloadSectionHeaderAttributes(sectionIndex: Int) -> TableElementAttributes {
        let sectionHeaderAttributes = strongSource().sectionHeaderAttributes(self, sectionIndex: sectionIndex)
        var sectionAttributes = sectionAttributesByIndex(sectionIndex)
        sectionAttributes.headerAttributes = sectionHeaderAttributes
        
        return sectionHeaderAttributes
    }
    
    private func _reloadSectionFooterAttributes(sectionIndex: Int) -> TableElementAttributes {
        let sectionFooterAttributes = strongSource().sectionFooterAttributes(self, sectionIndex: sectionIndex)
        var sectionAttributes = sectionAttributesByIndex(sectionIndex)
        sectionAttributes.footerAttributes = sectionFooterAttributes
        
        return sectionFooterAttributes
    }
    
    private func sectionAttributesByIndex(sectionIndex: Int) -> MutableTableSectionElementsAttributes {
        if let sectionAttributes = _sectionAttributesByIndex[sectionIndex] {
            return sectionAttributes
        }
        
        let sectionAttributes = MutableTableSectionElementsAttributes()
        _sectionAttributesByIndex[sectionIndex] = sectionAttributes
        
        return sectionAttributes
    }
    
    private func strongSource() -> TableElementAttributesCacheSource {
        guard let strongSource = source else {
            Debug.fatalError("TableElementAttributesCache source is nil")
        }
        
        return strongSource
    }
}
