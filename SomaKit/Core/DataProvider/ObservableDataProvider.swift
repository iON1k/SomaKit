//
//  ObservableDataProvider.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ObservableDataProvider<TData>: DataProviderType {
    public typealias DataType = TData
    
    private let sourceObservable: Observable<TData>
    
    public func rxData() -> Observable<DataType> {
        return sourceObservable
    }
    
    public init(sourceObservable: Observable<TData>) {
        self.sourceObservable = sourceObservable
    }
}

extension Observable {
    public func asDataProvider() -> ObservableDataProvider<E> {
        return ObservableDataProvider(sourceObservable: self)
    }
}