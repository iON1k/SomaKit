//
//  DataProviderType.swift
//  SomaKit
//
//  Created by Anton on 13.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol DataProviderType: ObservableConvertibleType {
    associatedtype DataType
    func data() -> Observable<DataType>
}

extension DataProviderType {
    public typealias E = DataType
    
    public func asObservable() -> Observable<DataType> {
        return data()
    }
}
