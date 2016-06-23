//
//  RequestError.swift
//  SomaKit
//
//  Created by Anton on 22.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public enum RequestError: ErrorType, CustomStringConvertible {
    case ServerError(code: Int, errString: String)
    case NetworkError(code: Int, errString: String)
    case UnknownError(errString: String)
    
    public var description: String {
        switch self {
        case .ServerError(_, let errString):
            return errString
        case .NetworkError(_, let errString):
            return errString
        case .UnknownError(let errString):
            return errString
        }
    }
}

public extension NSError {
    public func asRequestServerError() -> RequestError {
        return RequestError.ServerError(code: code, errString: domain)
    }
    
    public func asRequestNetworkError() -> RequestError {
        return RequestError.NetworkError(code: code, errString: domain)
    }
    
    public func asRequestUnknownError() -> RequestError {
        return RequestError.UnknownError(errString: domain)
    }
}