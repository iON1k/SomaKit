//
//  RequestBase.swift
//  SomaKit
//
//  Created by Anton on 16.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol RequestManagerType {
    func requestStarted<TRequest: RequestType>(request: TRequest)
    func requestFailed<TRequest: RequestType>(request: TRequest, error: ErrorType)
    func requestGetResponse<TRequest: RequestType>(request: TRequest, response: TRequest.ResponseType)
}

//default implementation
extension RequestManagerType {
    public func requestStarted<TRequest: RequestType>(request: TRequest) {
        Log.debug("Request started \(request)");
    }
    
    public func requestFailed<TRequest: RequestType>(request: TRequest, error: ErrorType) {
        Log.debug("Request failed \(request) with error \(error)");
    }
    
    public func requestGetResponse<TRequest: RequestType>(request: TRequest, response: TRequest.ResponseType) {
        Log.debug("Request \(request) get response \(response)");
    }
}

public class RequestBase<TResponse, TManager: RequestManagerType>: RequestType {
    public typealias ResponseType = TResponse
    public typealias ManagerType = TManager
    
    public func execute(manager: ManagerType) -> Observable<ResponseType> {
        return Observable.deferred({ () -> Observable<ResponseType> in
            manager.requestStarted(self)
            
            if let validationError = self._validateParams() {
                throw validationError
            }
            
            return self._requestEngine(manager)
        })
        .observeOn(_workingScheduler)
        .doOnNext({ (response) in
            if let responseError = self._validateResponse(response) {
                throw responseError
            }
        })
        .doOnNext({ (response) in
            manager.requestGetResponse(self, response: response)
        })
        .doOnError({ (error) in
            manager.requestFailed(self, error: error)
        })
        .subscribeOn(_workingScheduler)
    }
    
    public var _workingScheduler: ImmediateSchedulerType {
        return ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)
    }
    
    public func _validateParams() -> ErrorType? {
        return nil
    }
    
    public func _validateResponse(response: ResponseType) -> ErrorType? {
        return nil
    }
    
    public func _requestEngine(manager: ManagerType) -> Observable<ResponseType> {
        Utils.abstractMethod()
    }
}