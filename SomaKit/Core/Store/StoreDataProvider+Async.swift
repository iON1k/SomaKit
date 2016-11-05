//
//  StoreDataProvider+Async.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public extension StoreDataProvider {
    public func setDataInBackground(_ data: DataType) -> Observable<Void> {
        return Observable.deferred({ () -> Observable<Void> in
            return Observable.just(try self.setData(data))
        })
            .subcribeOnBackgroundScheduler()
    }
    
    public func loadDataInBackground() -> Observable<DataType?> {
        return Observable.deferred({ () -> Observable<DataType?> in
            return Observable.just(try self.loadData())
        })
            .subcribeOnBackgroundScheduler()
    }
}
