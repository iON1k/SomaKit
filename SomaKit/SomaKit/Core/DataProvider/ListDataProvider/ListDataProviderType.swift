//
//  ListDataProviderType.swift
//  SomaKit
//
//  Created by Anton on 09.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol ListDataProviderType: DataProviderType {
    associatedtype ItemType
    associatedtype DataType = [ItemType?]
    
    var items: DataType { get }
    var isAllItemsLoaded: Bool { get }
    
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
}

