//
//  Request.swift
//  SomaKit
//
//  Created by Anton on 15.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol RequestType {
    associatedtype ResponseType
    
    func rxResponse() -> Observable<ResponseType>
}