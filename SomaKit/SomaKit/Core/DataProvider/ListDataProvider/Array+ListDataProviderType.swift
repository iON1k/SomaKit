//
//  Array+ListDataProviderType.swift
//  SomaKit
//
//  Created by Anton on 10.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

extension Array: ListDataProviderType {
    public typealias ItemType = Element
    
    public var currentState: ListDataProviderState<Element> {
        return ListDataProviderState(items: self, isAllItemsLoaded: true)
    }
    
    public func loadItem(_ index: Int) -> Observable<ItemType?> {
        return Observable.just(index < count ? self[index] : nil)
    }
    
    public func state() -> Observable<ListDataProviderState<Element>> {
        return Observable.just(currentState)
    }
}
