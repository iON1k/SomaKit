//
//  ListDataProviderType.swift
//  SomaKit
//
//  Created by Anton on 09.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ListDataProviderState<ItemType> {
    public typealias ItemsType = [ItemType?]
    
    public let items: ItemsType
    public let isAllItemsLoaded: Bool
    
    public init(items: ItemsType, isAllItemsLoaded: Bool) {
        self.items = items
        self.isAllItemsLoaded = isAllItemsLoaded
    }
}

public protocol ListDataProviderType: DataProviderType {
    associatedtype ItemType
    associatedtype DataType = [ItemType?]
    
    typealias State = ListDataProviderState<ItemType>
    
    var currentState: State { get }
    
    func state() -> Observable<State>
    func loadItem(_ index: Int) -> Observable<ItemType?>
}

extension ListDataProviderType {
    public func loadItems(_ itemsRange: Range<Int>) -> Observable<[ItemType?]> {
        return Observable.from(Array(itemsRange.lowerBound..<itemsRange.upperBound))
            .map({ (index) -> Observable<ItemType?> in
                return self.loadItem(index)
            })
            .concat()
            .toArray()
    }
    
    public func data() -> Observable<[ItemType?]> {
        return state()
            .map({ (state) -> [ItemType?] in
                return state.items
            })
    }
}

