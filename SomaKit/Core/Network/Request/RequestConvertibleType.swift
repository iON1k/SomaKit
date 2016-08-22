//
//  RequestConvertibleType.swift
//  SomaKit
//
//  Created by Anton on 23.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol RequestConvertibleType {
    associatedtype ResponseType
    
    func asRequest() -> AnyRequest<ResponseType>
}
