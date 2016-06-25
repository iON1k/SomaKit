//
//  RequestDataLoader.swift
//  SomaKit
//
//  Created by Anton on 22.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public extension RequestType {
    public func asDataLoader(defaultValue: ResponseType) -> DataLoader<ResponseType> {
        return DataLoader(source: self.asObservable(), defaultValue: defaultValue)
    }
}

public extension RequestType where ResponseType: DefaultValueType {
    public func asDataLoader() -> DataLoader<ResponseType> {
        return asDataLoader(ResponseType.defaultValue)
    }
}