//
//  TableAttributedElementType.swift
//  SomaKit
//
//  Created by Anton on 11.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol TableAttributedElementType {
    static func tableElementAttributes(for viewModel: ViewModelType) -> TableElementAttributesType
    func bindTableElementAttributes(with attributes: TableElementAttributesType)
}
