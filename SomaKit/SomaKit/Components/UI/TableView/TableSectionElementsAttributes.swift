//
//  TableSectionElementsAttributes.swift
//  SomaKit
//
//  Created by Anton on 29.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public typealias CellsAttributes = [Int : TableElementAttributesType]

public struct TableSectionElementsAttributes {
    public let cellsAttributes: CellsAttributes
    public let headerAttributes: TableElementAttributesType?
    public let footerAttributes: TableElementAttributesType?
    
    public func mutableCopy() -> MutableTableSectionElementsAttributes {
        return MutableTableSectionElementsAttributes(cellsAttributes: cellsAttributes, headerAttributes: headerAttributes, footerAttributes: footerAttributes)
    }
    
    public init(cellsAttributes: CellsAttributes, headerAttributes: TableElementAttributesType? = nil, footerAttributes: TableElementAttributesType? = nil) {
        self.cellsAttributes = cellsAttributes
        self.headerAttributes = headerAttributes
        self.footerAttributes = footerAttributes
    }
}

public struct MutableTableSectionElementsAttributes {
    public var cellsAttributes = CellsAttributes()
    public var headerAttributes: TableElementAttributesType?
    public var footerAttributes: TableElementAttributesType?
    
    public func copy() -> TableSectionElementsAttributes {
        return TableSectionElementsAttributes(cellsAttributes: cellsAttributes, headerAttributes: headerAttributes, footerAttributes: footerAttributes)
    }
}
