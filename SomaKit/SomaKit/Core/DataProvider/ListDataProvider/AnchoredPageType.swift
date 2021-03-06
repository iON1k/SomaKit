//
//  AnchoredPageType.swift
//  SomaKit
//
//  Created by Anton on 25.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol AnchoredPageType: PageType {
    associatedtype AnchorType: Equatable
    
    var anchor: AnchorType { get }
}

open class AnchoredPage<TItem, TAnchor: Equatable>: Page<TItem>, AnchoredPageType {
    public typealias AnchorType = TAnchor
    
    public let anchor: AnchorType
    
    public init(items: [ItemType], anchor: AnchorType) {
        self.anchor = anchor
        
        super.init(items: items)
    }
}
