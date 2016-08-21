//
//  Array+ListDataProviderType.swift
//  SomaKit
//
//  Created by Anton on 10.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

extension Array: DataProviderType {
    public typealias ItemType = Element
    
    public var items: [ItemType?] {
        return self.optionalCovariance()
    }
    
    var isAllItemsLoaded: Bool {
        return true
    }
    
    public func loadItem(index: Int) -> Observable<ItemType?> {
        return Observable.just(index < count ? self[index] : nil)
    }
    
    public func dataObservable() -> Observable<[ItemType?]> {
        return Observable.just(self.optionalCovariance())
    }
}