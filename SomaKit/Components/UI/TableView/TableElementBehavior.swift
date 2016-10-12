//
//  TableElementBehavior.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol TableElementBehavior {
    static func tableElementAttributes(_ viewModel: ViewModelType) -> TableElementAttributes
    func bindTableElementAttributes(_ attributes: TableElementAttributes)
    func tableElementReset()
}

public extension TableElementBehavior {
    public func bindTableElementAttributes(_ attributes: TableElementAttributes) {
        //Nothing
    }
}
