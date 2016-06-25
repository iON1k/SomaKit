//
//  AnyRequest.swift
//  SomaKit
//
//  Created by Anton on 15.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class AnyRequest<TResponse>: RequestType {
    public typealias ResponseType = TResponse
    public typealias ResponseHandlerType = Void -> Observable<ResponseType>

    private let sourceResponseHandler: ResponseHandlerType
    
    public func rxResponse() -> Observable<ResponseType> {
        return sourceResponseHandler()
    }
    
    public init(_ sourceResponseHandler: ResponseHandlerType) {
        self.sourceResponseHandler = sourceResponseHandler
    }
}

public extension AnyRequest {
    public func asAnyRequest() -> AnyRequest<ResponseType> {
        return self
    }
}