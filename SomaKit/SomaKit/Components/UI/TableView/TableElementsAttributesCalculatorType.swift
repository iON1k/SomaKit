//
//  TableAttributesCalculatorType.swift
//  SomaKit
//
//  Created by Anton on 11.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol TableElementsAttributesCalculatorType {
    func cellAttributes(sectionIndex: Int, rowIndex: Int) -> TableElementAttributesType

    func sectionHeaderAttributes(sectionIndex: Int) -> TableElementAttributesType

    func sectionFooterAttributes(sectionIndex: Int) -> TableElementAttributesType
}
