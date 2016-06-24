//
//  AbstractApiClient.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift
import RxAlamofire
import Alamofire
import ObjectMapper

public class AbstractJSONApiClient: ApiRequestMaganer {
    private let alamoManager: Manager
    private let baseUrl: NSURL
    
    private let jsonMapper = UnsafeJSONMapper()
    
    public init(baseUrl: NSURL, alamoManager: Manager) {
        self.alamoManager = alamoManager
        self.baseUrl = baseUrl
    }
    
    public convenience init(baseUrl: NSURL) {
        self.init(baseUrl: baseUrl, alamoManager: Manager.sharedInstance)
    }
    
    public func _createRequest<TResponse: Mappable>(methodType: ApiMethodType, apiMethod: String,
                              params: ApiRequest<TResponse>.ParamsType) -> ApiRequest<TResponse> {
        jsonMapper.registerTypeIfNeeded(TResponse)
        return ApiRequest(manager: self, methodType: methodType, apiMethod: apiMethod, params: params)
    }
    
    public func apiRequestRunningEngine<TResponse>(request: ApiRequest<TResponse>) throws -> Observable<Any> {
        let anyObjectsParams = try request.params.mapValues { (value) throws -> AnyObject in
            guard let newValue = value as? AnyObject else {
                throw SomaError("Api request parameter \(value) wrong type.")
            }
            
            return newValue
        }
        
        let urlString = try buildURLString(request.apiMethod)
        return alamoManager.rx_string(alamoApiMethodType(request.methodType), urlString, parameters: anyObjectsParams)
            .doOnNext({ (responseString) in
                Log.debug("Api request get response: \(responseString)")
            })
            .map(SomaFunc.emptyTransform)
    }
    
    public func apiResponseMappingEngine<TResponse>(request: ApiRequest<TResponse>, sourceResponse: Any) -> Observable<TResponse> {
        return Observable.deferred({ () -> Observable<TResponse> in
            guard let responeString = sourceResponse as? String else {
                throw SomaError("Wrong response type. Expected string.")
            }
            
            return Observable.just(try self.jsonMapper.map(responeString))
        })
    }
    
    public func apiRequestHandleError<TResponse>(request: ApiRequest<TResponse>, error: ErrorType) {
        Log.debug("Api request get error \(error)")
    }
    
    public func apiRequestCompleted<TResponse>(request: ApiRequest<TResponse>, response: TResponse) {
        //Nothing
    }
    
    private func buildURLString(endPoint: String) throws -> String {
        let url = NSURL(string: endPoint, relativeToURL: baseUrl)
        
        if let url = url {
            return url.absoluteString
        }
        
        throw SomaError("URL building with endpoint \(endPoint) failed")
    }
    
    private func alamoApiMethodType(somaApiMethod: ApiMethodType) -> Alamofire.Method {
        switch somaApiMethod {
        case .Get:
            return .GET
        case .Post:
            return .POST
        }
    }
}