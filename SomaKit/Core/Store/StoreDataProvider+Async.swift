//
//  StoreDataProvider+Async.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public extension StoreDataProvider {
    public func setDataAsync(data: DataType) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            do {
                try self.setData(data)
                observer.onNext()
                observer.onCompleted()
            } catch let error {
                observer.onError(error)
            }
            
            return NopDisposable.instance
        })
            .subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default))
    }
    
    public func loadDataAsync() -> Observable<DataType> {
        return Observable.create({ (observer) -> Disposable in
            do {
                let data = try self.loadData()
                observer.onNext(data)
                observer.onCompleted()
            } catch let error {
                observer.onError(error)
            }
            
            return NopDisposable.instance
        })
            .subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default))
    }
}