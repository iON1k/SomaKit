//
//  TableElementPresenter.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol TableElementBehavior {
    static func tableElementAttributes(_ viewModel: ViewModelType) -> TableElementAttributesType
    func bindTableElementAttributes(_ attributes: TableElementAttributesType)
    func tableElementReset()
}

public extension TableElementBehavior {
    public func bindTableElementAttributes(_ attributes: TableElementAttributesType) {
        //Nothing
    }
}
