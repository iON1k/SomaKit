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
    var isLastPage: Bool { get }
}

public class SimpleItemsPage<TItem>: ItemsPageType {
    public typealias ItemType = TItem
    
    public let items: [ItemType]
    private let pageSize: Int
    
    public var isLastPage: Bool {
        return items.count < pageSize
    }
    
    public init(pageSize: Int, items: [ItemType]) {
        self.pageSize = pageSize
        self.items = items
    }
}
