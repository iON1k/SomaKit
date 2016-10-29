//
//  TableElementAttributesCache.swift
//  SomaKit
//
//  Created by Anton on 24.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol TableElementAttributesCacheSource: class {
    func sectionHeaderAttributes(_ tableElementAttributesCache: TableElementAttributesCache, sectionIndex: Int) -> TableElementAttributesType
    func sectionFooterAttributes(_ tableElementAttributesCache: TableElementAttributesCache, sectionIndex: Int) -> TableElementAttributesType
    func cellAttributes(_ tableElementAttributesCache: TableElementAttributesCache, indexPath: IndexPath) -> TableElementAttributesType
}

open class TableElementAttributesCache {
    private typealias SectionsAttributesByIndexType = [Int : MutableTableSectionElementsAttributes]
    open weak var source: TableElementAttributesCacheSource?
    
    private var _sectionAttributesByIndex = SectionsAttributesByIndexType()
    
    open func cellAttributes(_ indexPath: IndexPath) -> TableElementAttributesType {
        Utils.ensureIsMainThread()
        
        let sectionAttributes = sectionAttributesByIndex((indexPath as NSIndexPath).section)
        if let cellAttributes = sectionAttributes.cellsAttributes[(indexPath as NSIndexPath).row] {
            return cellAttributes
        }
        
        return _reloadCellAttributes(indexPath)
    }
    
    open func sectionHeaderAttributes(_ sectionIndex: Int) -> TableElementAttributesType {
        Utils.ensureIsMainThread()
        
        let sectionAttributes = sectionAttributesByIndex(sectionIndex)
        if let sectionHeaderAttributes = sectionAttributes.headerAttributes {
            return sectionHeaderAttributes
        }
        
        return _reloadSectionHeaderAttributes(sectionIndex)
    }
    
    open func sectionFooterAttributes(_ sectionIndex: Int) -> TableElementAttributesType {
        Utils.ensureIsMainThread()
        
        let sectionAttributes = sectionAttributesByIndex(sectionIndex)
        if let sectionFooterAttributes = sectionAttributes.footerAttributes {
            return sectionFooterAttributes
        }
        
        return _reloadSectionFooterAttributes(sectionIndex)
    }
    
    open func sectionAttributes(_ sectionIndex: Int) -> TableSectionElementsAttributes {
        Utils.ensureIsMainThread()
        
        return sectionAttributesByIndex(sectionIndex).copy()
    }
    
    open func resetCacheWithPreloadedData(_ preloadedData: [TableSectionElementsAttributes]) {
        invalidateCache()
        
        for (index, sectionData) in preloadedData.enumerated() {
            _sectionAttributesByIndex[index] = sectionData.mutableCopy()
        }
    }
    
    open func invalidateCache() {
        Utils.ensureIsMainThread()
        
        _sectionAttributesByIndex.removeAll()
    }
    
    open func invalidateSectionCache(_ sectionIndex: Int) {
        Utils.ensureIsMainThread()
        
        _sectionAttributesByIndex.removeValue(forKey: sectionIndex)
    }
    
    open func invalidateCellCache(_ indexPath: IndexPath) {
        Utils.ensureIsMainThread()
        
        var sectionAttributes = sectionAttributesByIndex((indexPath as NSIndexPath).section)
        sectionAttributes.cellsAttributes.removeValue(forKey: (indexPath as NSIndexPath).row)
    }
    
    open func invalidateSectionHeaderCache(_ sectionIndex: Int) {
        Utils.ensureIsMainThread()
        
        var sectionAttributes = sectionAttributesByIndex(sectionIndex)
        sectionAttributes.headerAttributes = nil
    }
    
    open func invalidateSectionFooterCache(_ sectionIndex: Int) {
        Utils.ensureIsMainThread()
        
        var sectionAttributes = sectionAttributesByIndex(sectionIndex)
        sectionAttributes.footerAttributes = nil
    }
    
    open func reloadCellAttributes(_ indexPath: IndexPath) {
        Utils.ensureIsMainThread()
        
        _ = _reloadCellAttributes(indexPath)
    }
    
    open func reloadSectionHeaderAttributes(_ sectionIndex: Int) {
        Utils.ensureIsMainThread()
        
        _ = _reloadSectionHeaderAttributes(sectionIndex)
    }
    
    open func reloadSectionFooterAttributes(_ sectionIndex: Int) {
        Utils.ensureIsMainThread()
        
        _ = _reloadSectionFooterAttributes(sectionIndex)
    }
    
    private func _reloadCellAttributes(_ indexPath: IndexPath) -> TableElementAttributesType {
        let cellAttributes = strongSource().cellAttributes(self, indexPath: indexPath)
        var sectionAttributes = sectionAttributesByIndex((indexPath as NSIndexPath).section)
        sectionAttributes.cellsAttributes[(indexPath as NSIndexPath).row] = cellAttributes
        
        return cellAttributes
    }
    
    private func _reloadSectionHeaderAttributes(_ sectionIndex: Int) -> TableElementAttributesType {
        let sectionHeaderAttributes = strongSource().sectionHeaderAttributes(self, sectionIndex: sectionIndex)
        var sectionAttributes = sectionAttributesByIndex(sectionIndex)
        sectionAttributes.headerAttributes = sectionHeaderAttributes
        
        return sectionHeaderAttributes
    }
    
    private func _reloadSectionFooterAttributes(_ sectionIndex: Int) -> TableElementAttributesType {
        let sectionFooterAttributes = strongSource().sectionFooterAttributes(self, sectionIndex: sectionIndex)
        var sectionAttributes = sectionAttributesByIndex(sectionIndex)
        sectionAttributes.footerAttributes = sectionFooterAttributes
        
        return sectionFooterAttributes
    }
    
    private func sectionAttributesByIndex(_ sectionIndex: Int) -> MutableTableSectionElementsAttributes {
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
