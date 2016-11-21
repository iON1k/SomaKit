//
//  RequestType.swift
//  SomaKit
//
//  Created by Anton on 15.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol RequestType: ObservableConvertibleType {
    associatedtype ResponseType

    func response() -> Observable<ResponseType>
}

extension RequestType {
    public typealias E = ResponseType
    
    public func asObservable() -> Observable<ResponseType> {
        return response()
    }
}
