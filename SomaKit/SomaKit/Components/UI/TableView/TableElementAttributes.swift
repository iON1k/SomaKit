//
//  TableElementAttributes.swift
//  SomaKit
//
//  Created by Anton on 11.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

open class TableElementAttributes: TableElementAttributesType {
    private let prefferedHeight: CGFloat

    public var estimatedHeight: CGFloat {
        return prefferedHeight
    }

    public init(prefferedHeight: CGFloat) {
        self.prefferedHeight = prefferedHeight
    }
}
