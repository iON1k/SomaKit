//
//  AnchoredPageType.swift
//  SomaKit
//
//  Created by Anton on 25.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol AnchoredPageType: ItemsPageType {
    associatedtype AnchorType: Equatable
    
    var anchor: AnchorType { get }
}

public class SimpleAnchoredPage<TItem, TAnchor: Equatable>: SimpleItemsPage<TItem>, AnchoredPageType {
    public typealias AnchorType = TAnchor
    
    public let anchor: AnchorType
    
    public init(items: [ItemType], anchor: AnchorType) {
        self.anchor = anchor
        
        super.init(items: items)
    }
}