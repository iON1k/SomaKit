//
//  Observable+DataProviderType.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

extension Observable: DataProviderConvertibleType {
    public typealias DataType = E
    
    public func asAnyDataProvider() -> AnyDataProvider<DataType> {
        return AnyDataProvider() {
            return self
        }
    }
}