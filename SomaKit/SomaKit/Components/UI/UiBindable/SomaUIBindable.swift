//
//  SomaUIBindable.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class SomaUIBindable: UiBindableType {
    private let isBindedSubject: BehaviorSubject<Bool>
    private let isActiveSubject: BehaviorSubject<Bool>
    
    private let scheduler: ImmediateSchedulerType?
    
    public init(isBindedSubject: BehaviorSubject<Bool>, isActiveSubject: BehaviorSubject<Bool>, scheduler: ImmediateSchedulerType? = nil) {
        self.isBindedSubject = isBindedSubject
        self.isActiveSubject = isActiveSubject
        self.scheduler = scheduler
    }
    
    public func whileBinded<TObservable: ObservableType>(_ observable: TObservable) -> Observable<TObservable.E> {
        let unbindingObservable = isBindedSubject.scan((false, false)) { (prevValues, curValue) -> (Bool, Bool) in
                return (prevValues.1, curValue)
            }
            .filter { (values) -> Bool in
                return values.0 && !values.1
            }
        
        return isBindedSubject
            .flatMapLatest({ (isBinded) -> Observable<TObservable.E> in
                return isBinded ? self.applyScheduler(observable.asObservable()) : Observable.never()
            })
            .takeUntil(unbindingObservable)
    }
    
    public func whileActive<TObservable: ObservableType>(_ observable: TObservable) -> Observable<TObservable.E> {
        return isActiveSubject
            .flatMapLatest({ (isActive) -> Observable<TObservable.E> in
                return isActive ? observable.asObservable() : Observable.never()
            })
            .whileBinded(self)
    }
    
    private func applyScheduler<T>(_ observable: Observable<T>) -> Observable<T> {
        if let scheduler = scheduler {
            return observable.observeOn(scheduler)
        }
        
        return observable
    }
}
