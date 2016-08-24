//
//  AlamoRequestManager.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift
import RxAlamofire
import Alamofire
import ObjectMapper

public class AlamoRequestManager: ApiRequestManagerType {
    private let alamoManager: Manager
    private let baseUrl: URLConvertible
    private let responseMapper: _StringMapperType
    
    public init(baseUrl: URLConvertible, alamoManager: Manager = Manager.sharedInstance, responseMapper: _StringMapperType = JsonMapper()) {
        self.alamoManager = alamoManager
        self.baseUrl = baseUrl
        self.responseMapper = responseMapper
    }
    
    public func apiRequestEngine<TRequest: RequestType where TRequest: ApiParamsProvider>(request: TRequest) -> Observable<TRequest.ResponseType> {
        return Observable.deferred({ () -> Observable<TRequest.ResponseType> in
            let urlString = try self.buildURLString(request.method)
            let alamoMethodType = try self.alamoMethodType(request.methodType)
            return self.alamoManager.rx_string(alamoMethodType, urlString,
                parameters: request.params, encoding: self._parametersEncoding, headers: request.headers)
                .map({ (responseString) -> TRequest.ResponseType in
                    return try self.responseMapper.mapToModel(responseString)
                })
        })
    }
    
    public var _parametersEncoding: ParameterEncoding {
        return .URL
    }
    
    private func buildURLString(endPoint: String) throws -> String {
        let url = NSURL(string: endPoint, relativeToURL: baseUrl.url)
        
        if let url = url {
            return url.absoluteString
        }
        
        throw SomaError("URL building with endpoint \(endPoint) failed")
    }
    
    private func alamoMethodType(somaMethodType: ApiMethodType) throws -> Alamofire.Method {
        guard let alamoMethod = Alamofire.Method.init(rawValue: somaMethodType.rawValue) else {
            throw SomaError("Alamofire doesn't have api method type \(somaMethodType)")
        }
        
        return alamoMethod
    }
}