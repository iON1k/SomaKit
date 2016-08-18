//
//  Observable+Extensions.swift
//  SomaKit
//
//  Created by Anton on 22.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public extension Observable where Element: OptionalValueType {
    public func ignoreNil() -> Observable<E.Wrapped> {
        return self.filter({ (element) -> Bool in
                return element.hasValue
            })
            .map({ (element) -> E.Wrapped in
                return element.value
            })
    }
}

public extension Observable {
    public func subcribeOnBackgroundScheduler() -> Observable<E> {
        return self.subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default))
    }
    
    public func observeOnBackgroundScheduler() -> Observable<E> {
        return self.observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default))
    }
    
    public func subcribeOnMainScheduler() -> Observable<E> {
        return self.subscribeOn(MainScheduler.instance)
    }
    
    public func observeOnMainScheduler() -> Observable<E> {
        return self.observeOn(MainScheduler.instance)
    }
}