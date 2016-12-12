//
//  TableElementsAttributesCalculator.swift
//  SomaKit
//
//  Created by Anton on 24.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol TableElementsAttributesCalculatorEngineType {
    func calculateSectionHeaderAttributes(sectionIndex: Int) -> TableElementAttributesType
    func calculateSectionFooterAttributes(sectionIndex: Int) -> TableElementAttributesType
    func calculateCellAttributes(sectionIndex: Int, rowIndex: Int) -> TableElementAttributesType
}

public class TableElementsAttributesCalculator: TableElementsAttributesCalculatorType {
    private class SectionAttributes {
        public var cellsAttributes = [Int : TableElementAttributesType]()
        public var headerAttributes: TableElementAttributesType?
        public var footerAttributes: TableElementAttributesType?
    }

    private let engine: TableElementsAttributesCalculatorEngineType
    
    private var sectionAttributesByIndex = [Int : SectionAttributes]()

    public init(engine: TableElementsAttributesCalculatorEngineType) {
        self.engine = engine
    }

    public func cellAttributes(sectionIndex: Int, rowIndex: Int) -> TableElementAttributesType {
        let sectionAttributes = self.sectionAttributes(sectionIndex: sectionIndex)
        if let cellAttributes = sectionAttributes.cellsAttributes[rowIndex] {
            return cellAttributes
        }
        
        return calculateCellAttributes(sectionIndex: sectionIndex, rowIndex: rowIndex)
    }
    
    public func sectionHeaderAttributes(sectionIndex: Int) -> TableElementAttributesType {
        let sectionAttributes = self.sectionAttributes(sectionIndex: sectionIndex)
        if let sectionHeaderAttributes = sectionAttributes.headerAttributes {
            return sectionHeaderAttributes
        }
        
        return calculateSectionHeaderAttributes(sectionIndex: sectionIndex)
    }
    
    public func sectionFooterAttributes(sectionIndex: Int) -> TableElementAttributesType {
        let sectionAttributes = self.sectionAttributes(sectionIndex: sectionIndex)
        if let sectionFooterAttributes = sectionAttributes.footerAttributes {
            return sectionFooterAttributes
        }
        
        return calculateSectionFooterAttributes(sectionIndex: sectionIndex)
    }
    
    public func reloadCellAttributes(sectionIndex: Int, rowIndex: Int) {
        _ = calculateCellAttributes(sectionIndex: sectionIndex, rowIndex: rowIndex)
    }
    
    public func reloadSectionHeaderAttributes(sectionIndex: Int) {
        _ = calculateSectionHeaderAttributes(sectionIndex: sectionIndex)
    }
    
    public func reloadSectionFooterAttributes(sectionIndex: Int) {
        _ = calculateSectionFooterAttributes(sectionIndex: sectionIndex)
    }
    
    private func calculateCellAttributes(sectionIndex: Int, rowIndex: Int) -> TableElementAttributesType {
        let cellAttributes = engine.calculateCellAttributes(sectionIndex: sectionIndex, rowIndex: rowIndex)
        let sectionAttributes = self.sectionAttributes(sectionIndex: sectionIndex)
        sectionAttributes.cellsAttributes[rowIndex] = cellAttributes
        
        return cellAttributes
    }
    
    private func calculateSectionHeaderAttributes(sectionIndex: Int) -> TableElementAttributesType {
        let sectionHeaderAttributes = engine.calculateSectionHeaderAttributes(sectionIndex: sectionIndex)
        let sectionAttributes = self.sectionAttributes(sectionIndex: sectionIndex)
        sectionAttributes.headerAttributes = sectionHeaderAttributes
        
        return sectionHeaderAttributes
    }
    
    private func calculateSectionFooterAttributes(sectionIndex: Int) -> TableElementAttributesType {
        let sectionFooterAttributes = engine.calculateSectionFooterAttributes(sectionIndex: sectionIndex)
        let sectionAttributes = self.sectionAttributes(sectionIndex: sectionIndex)
        sectionAttributes.footerAttributes = sectionFooterAttributes
        
        return sectionFooterAttributes
    }
    
    private func sectionAttributes(sectionIndex: Int) -> SectionAttributes {
        if let sectionAttributes = sectionAttributesByIndex[sectionIndex] {
            return sectionAttributes
        }
        
        let sectionAttributes = SectionAttributes()
        sectionAttributesByIndex[sectionIndex] = sectionAttributes
        
        return sectionAttributes
    }
}
