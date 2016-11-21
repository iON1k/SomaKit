//
//  ApiPartBase.swift
//  SomaKit
//
//  Created by Anton on 21.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import ObjectMapper
import RxSwift

open class ApiPartBase<TManager: ApiRequestManagerType> {
    private let requestManager: TManager
    
    public init(requestManager: TManager) {
        self.requestManager = requestManager
    }
    
    open func _request<TRequest: RequestType>(_ requestFactory: (TManager) -> TRequest) -> TRequest where TRequest.ResponseType: Mappable {
        return requestFactory(requestManager)
    }
}
