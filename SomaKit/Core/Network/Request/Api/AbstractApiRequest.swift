//
//  AbstractApiRequest.swift
//  SomaKit
//
//  Created by Anton on 16.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol RequestManagerType {
    func requestStarted<TRequest: RequestType>(_ request: TRequest)
    func requestFailed<TRequest: RequestType>(_ request: TRequest, error: Error)
    func requestGetResponse<TRequest: RequestType>(_ request: TRequest, response: TRequest.ResponseType)
}

//default implementation
extension RequestManagerType {
    public func requestStarted<TRequest: RequestType>(_ request: TRequest) {
        Log.debug("Request started \(request)");
    }
    
    public func requestFailed<TRequest: RequestType>(_ request: TRequest, error: Error) {
        Log.debug("Request failed \(request) with error \(error)");
    }
    
    public func requestGetResponse<TRequest: RequestType>(_ request: TRequest, response: TRequest.ResponseType) {
        Log.debug("Request \(request) get response \(response)");
    }
}

open class AbstractApiRequest<TResponse, TManager: RequestManagerType>: RequestType {
    public typealias ResponseType = TResponse
    public typealias ManagerType = TManager
    
    open let _manager: ManagerType
    
    open func response() -> Observable<ResponseType> {
        return Observable.deferred({ () -> Observable<ResponseType> in
            self._manager.requestStarted(self)
            
            try self._validateParams()
            
            return self.execute()
        })
            .do(onNext: { (response) in
                self._manager.requestGetResponse(self, response: response)
            })
            .do(onError: { (error) in
                self._manager.requestFailed(self, error: error)
            })
            .subscribeOn(_workingScheduler)
    }
    
    private func execute() -> Observable<ResponseType> {
        return _requestEngine()
            .observeOn(_workingScheduler)
            .do(onNext: { (response) in
                try self._validateResponse(response)
            })
    }
    
    public init(manager: ManagerType) {
        self._manager = manager
    }
    
    open var _workingScheduler: ImmediateSchedulerType {
        return ConcurrentDispatchQueueScheduler(qos: .default)
    }
    
    open func _validateParams() throws -> Void {
        //Nothing
    }
    
    open func _validateResponse(_ response: ResponseType) throws -> Void {
        //Nothing
    }
    
    open func _requestEngine() -> Observable<ResponseType> {
        Utils.abstractMethod()
    }
}
