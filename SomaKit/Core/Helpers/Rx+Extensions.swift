//
//  Rx+Extensions.swift
//  SomaKit
//
//  Created by Anton on 22.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public extension Observable where Element: OptionalType {
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
        return self.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    public func observeOnBackgroundScheduler() -> Observable<E> {
        return self.observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    public func subcribeOnMainScheduler() -> Observable<E> {
        return self.subscribeOn(MainScheduler.instance)
    }
    
    public func observeOnMainScheduler() -> Observable<E> {
        return self.observeOn(MainScheduler.instance)
    }
}

public extension Observable {
    public func catchErrorNoReturn() -> Observable<E> {
        return self.catchError({ (error) -> Observable<E> in
            return Observable.empty()
        })
    }
}

infix operator <=
func <= <TResult>(variable: Variable<TResult>, newValue: TResult) -> Void {
    variable.value = newValue
}

public extension Observable {
    public func mapToJust<TElement>(_ element: TElement) -> Observable<TElement> {
        return self.map({ (_) -> TElement in
            return element
        })
    }
}
