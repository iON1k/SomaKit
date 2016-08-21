//
//  RequestType.swift
//  SomaKit
//
//  Created by Anton on 15.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol RequestType: DataProviderConvertibleType {
    associatedtype ResponseType

    func response() -> Observable<ResponseType>
}

extension RequestType {
    public func asAnyDataProvider() -> AnyDataProvider<ResponseType> {
        return AnyDataProvider(response)
    }
}