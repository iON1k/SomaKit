//
//  AnyRequest.swift
//  SomaKit
//
//  Created by Anton on 23.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class AnyRequest<TResponse>: RequestType {
    public typealias ResponseType = TResponse
    public typealias ResponseHandlerType = Void -> Observable<ResponseType>
    
    private let responseHandler: ResponseHandlerType
    
    public func response() -> Observable<ResponseType> {
        return responseHandler()
    }
    
    public init(_ responseHandler: ResponseHandlerType) {
        self.responseHandler = responseHandler
    }
}

extension AnyRequest {
    public func asRequest() -> AnyRequest<ResponseType> {
        return self
    }
}
