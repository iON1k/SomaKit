//
//  AnyStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class AnyStore<TKey, TData>: HandleStore<TKey, TData> {
    public init<TStore: StoreType where TStore.KeyType == KeyType,
        TStore.DataType == DataType>(sourceStore: TStore) {
        super.init(loadDataHandler: sourceStore.loadData, saveDataHandler: sourceStore.saveData)
    }
}

extension StoreType {
    public func asAny() -> AnyStore<KeyType, DataType> {
        return AnyStore(sourceStore: self)
    }
}