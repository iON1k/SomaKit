//
//  ItemsPageType.swift
//  SomaKit
//
//  Created by Anton on 11.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol ItemsPageType {
    associatedtype ItemType
    
    var items: [ItemType] { get }
}

open class SimpleItemsPage<TItem>: ItemsPageType {
    public typealias ItemType = TItem
    
    open let items: [ItemType]
    
    public init(items: [ItemType]) {
        self.items = items
    }
}
