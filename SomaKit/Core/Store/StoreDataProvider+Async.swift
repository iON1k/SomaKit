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
        return Observable.deferred({ () -> Observable<Void> in
            return Observable.just(try self.setData(data))
        })
            .subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default))
    }
    
    public func loadDataAsync() -> Observable<DataType?> {
        return Observable.deferred({ () -> Observable<DataType?> in
            return Observable.just(try self.loadData())
        })
            .subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default))
    }
}