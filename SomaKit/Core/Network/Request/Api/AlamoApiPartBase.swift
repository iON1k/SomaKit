//
//  AlamoApiPartBase.swift
//  SomaKit
//
//  Created by Anton on 21.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import ObjectMapper

public class AlamoApiPartBase<TManager: AlamoJsonRequestManager> {
    private let requestManager: TManager
    
    public init(requestManager: TManager) {
        self.requestManager = requestManager
    }
    
    public func _request<TRequest: RequestType where TRequest.ResponseType: Mappable>(requestFactory: TManager -> TRequest) -> TRequest {
        requestManager.registerResponse(TRequest.ResponseType.self)
        return requestFactory(requestManager)
    }
}

