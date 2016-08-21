//
//  DataLoader.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class DataLoader<TData>: DataProviderType {
    public typealias DataType = TData
    public typealias SourceDataHandler = Void -> Observable<DataType>
    
    private let dataValue = Variable<DataType?>(nil)
    private let sourceProvider: AnyDataProvider<TData>
    
    private let syncLock = SyncLock()
    private var loadingObservable: Observable<DataType>?
    
    public func dataObservable() -> Observable<DataType> {
        return dataValue.asObservable()
            .ignoreNil()
    }
    
    public func loadData() -> Observable<DataType> {
        return Observable.deferred({ () -> Observable<DataType> in
            return self.syncLock.sync({ () -> Observable<DataType> in
                if let loadingObservable = self.loadingObservable {
                    return loadingObservable
                } else {
                    let loadingObservable =
                        self.sourceProvider.dataObservable()
                        .doOnNext { (data) in
                            self.dataValue <= data
                        }
                        .shareReplay(1)
                    
                    self.loadingObservable = loadingObservable
                    return loadingObservable
                }
            })
        })
    }
    
    public init<TDataProvider: DataProviderConvertibleType where TDataProvider.DataType == DataType>(dataProvider: TDataProvider) {
        self.sourceProvider = dataProvider.asAnyDataProvider()
    }
}

public extension DataProviderConvertibleType {
    public func asDataLoader() -> DataLoader<DataType> {
        return DataLoader(dataProvider: self)
    }
}
