//
//  StoreType+Background.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public extension StoreType {
    public func saveDataInBackground(_ key: KeyType, data: DataType?) -> Observable<Void> {
        return Observable.deferred({ () -> Observable<Void> in
            return Observable.just(try self.saveData(key, data: data))
        })
            .subcribeOnBackgroundScheduler()
    }
    
    public func loadDataInBackground(_ key: KeyType) -> Observable<DataType?> {
        return Observable.deferred({ () -> Observable<DataType?> in
            return Observable.just(try self.loadData(key))
        })
            .subcribeOnBackgroundScheduler()
    }
}
