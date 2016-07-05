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
    
    public func onBinded<T>(observable: Observable<T>) -> Observable<T> {
        return isBindedSubject
            .flatMapLatest({ (isBinded) -> Observable<T> in
                return isBinded ? self.applyScheduler(observable) : Observable.never()
            })
            .takeUntil(isBindedSubject.filter(SomaFunc.negativePredicate))
    }
    
    public func onActive<T>(observable: Observable<T>) -> Observable<T> {
        return isActiveSubject
            .flatMapLatest({ (isActive) -> Observable<T> in
                return isActive ? observable : Observable.never()
            })
            .bindOn(self)
    }
    
    private func applyScheduler<T>(observable: Observable<T>) -> Observable<T> {
        if let scheduler = scheduler {
            return observable.observeOn(scheduler)
        }
        
        return observable
    }
}
