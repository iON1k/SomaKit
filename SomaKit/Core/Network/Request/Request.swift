//
//  Request.swift
//  SomaKit
//
//  Created by Anton on 15.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol RequestType: ObservableConvertibleType, DataProviderConvertibleType {
    associatedtype ResponseType
    
    func rxResponse() -> Observable<ResponseType>
}

extension RequestType {
    public typealias E = ResponseType
    
    public func asObservable() -> Observable<ResponseType> {
        return Observable.deferred({ () -> Observable<ResponseType> in
            return self.rxResponse()
        })
    }
}

extension RequestType {
    public typealias DataType = ResponseType
    
    public func asDataProvider() -> AnyDataProvider<ResponseType> {
        return self.asAny()
    }
}