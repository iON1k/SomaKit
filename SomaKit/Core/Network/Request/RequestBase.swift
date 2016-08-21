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
    
    public let _manager: ManagerType
    
    public func response() -> Observable<ResponseType> {
        return Observable.deferred({ () -> Observable<ResponseType> in
            self._manager.requestStarted(self)
            
            if let validationError = self._validateParams() {
                throw validationError
            }
            
            return self.execute()
        })
        .doOnNext({ (response) in
            self._manager.requestGetResponse(self, response: response)
        })
        .doOnError({ (error) in
            self._manager.requestFailed(self, error: error)
        })
        .subscribeOn(_workingScheduler)
    }
    
    private func execute() -> Observable<ResponseType> {
        return self._requestEngine()
            .observeOn(_workingScheduler)
            .doOnNext({ (response) in
                if let responseError = self._validateResponse(response) {
                    throw responseError
                }
            })
            .retryWhen({ (errors) -> Observable<Void> in
                return self._retryOnErrors(errors)
            })
    }
    
    public init(manager: ManagerType) {
        self._manager = manager
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
    
    public func _requestEngine() -> Observable<ResponseType> {
        Utils.abstractMethod()
    }
    
    public func _retryOnErrors(errors: Observable<ErrorType>) -> Observable<Void> {
        return Observable.empty()
    }
}