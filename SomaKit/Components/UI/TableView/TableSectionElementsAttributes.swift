//
//  TableSectionElementsAttributes.swift
//  SomaKit
//
//  Created by Anton on 29.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public typealias CellsAttributes = [Int : TableElementAttributes]

public struct TableSectionElementsAttributes {
    public let cellsAttributes: CellsAttributes
    public let headerAttributes: TableElementAttributes?
    public let footerAttributes: TableElementAttributes?
    
    public init(cellsAttributes: CellsAttributes, headerAttributes: TableElementAttributes? = nil, footerAttributes: TableElementAttributes? = nil) {
        self.cellsAttributes = cellsAttributes
        self.headerAttributes = headerAttributes
        self.footerAttributes = footerAttributes
    }
    
    public func mutableCopy() -> MutableTableSectionElementsAttributes {
        return MutableTableSectionElementsAttributes(cellsAttributes: cellsAttributes, headerAttributes: headerAttributes, footerAttributes: footerAttributes)
    }
}

public struct MutableTableSectionElementsAttributes {
    public var cellsAttributes = CellsAttributes()
    public var headerAttributes: TableElementAttributes?
    public var footerAttributes: TableElementAttributes?
    
    public func copy() -> TableSectionElementsAttributes {
        return TableSectionElementsAttributes(cellsAttributes: cellsAttributes, headerAttributes: headerAttributes, footerAttributes: footerAttributes)
    }
}