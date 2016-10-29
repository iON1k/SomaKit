//
//  TableElementAttributesType.swift
//  SomaKit
//
//  Created by Anton on 24.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol TableElementAttributesType {
    var estimatedHeight: CGFloat { get }
}

open class TableElementAttributes: TableElementAttributesType {
    private let prefferedHeight: CGFloat
    
    public var estimatedHeight: CGFloat {
        return prefferedHeight
    }
    
    public init(prefferedHeight: CGFloat) {
        self.prefferedHeight = prefferedHeight
    }
}
