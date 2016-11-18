//
//  PageType.swift
//  SomaKit
//
//  Created by Anton on 11.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol PageType {
    associatedtype ItemType
    
    var items: [ItemType] { get }
}

open class Page<TItem>: PageType {
    public typealias ItemType = TItem
    
    public let items: [ItemType]
    
    public init(items: [ItemType]) {
        self.items = items
    }
}
