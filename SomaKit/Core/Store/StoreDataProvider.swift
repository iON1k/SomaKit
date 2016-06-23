//
//  StoreDataProvider.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class StoreDataProvider<TStore: StoreType>: DataProviderType {
    public typealias DataType = TStore.DataType
    public typealias StoreKeyType = TStore.KeyType
    
    private let dataValue: Variable<DataType>
    private let store: TStore
    private let key: StoreKeyType
    
    public func rxData() -> Observable<DataType> {
        return dataValue.asObservable()
    }
    
    public init(store: TStore, key: StoreKeyType, defaultValue: DataType) {
        dataValue = Variable(defaultValue)
        self.store = store
        self.key = key
    }
    
    public func updateData(data: DataType) throws {
        try store.saveData(key, data: data)
        dataValue.value = data
    }
    
    public func loadData() throws -> DataType {
        let data = try store.loadData(key)
        dataValue.value = data
        return data
    }
}

extension StoreDataProvider {
    public func updateDataAsync(data: DataType) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            do {
                try self.updateData(data)
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

