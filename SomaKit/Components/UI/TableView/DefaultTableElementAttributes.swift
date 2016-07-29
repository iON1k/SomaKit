//
//  DefaultTableElementAttributes.swift
//  SomaKit
//
//  Created by Anton on 29.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public struct DefaultTableElementAttributes: TableElementAttributes {
    private let prefferedHeight: CGFloat
    
    public var estimatedHeight: CGFloat {
        return prefferedHeight
    }
    
    public init(prefferedHeight: CGFloat) {
        self.prefferedHeight = prefferedHeight
    }
}
