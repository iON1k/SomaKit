//
//  TableElementBehavior.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol TableElementBehavior {
    static func tableElementAttributes(viewModel: ViewModelType) -> TableElementAttributes
    func bindTableElementAttributes(attributes: TableElementAttributes)
    func tableElementReset()
}
