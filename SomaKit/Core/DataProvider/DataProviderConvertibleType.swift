//
//  DataProviderConvertibleType.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public protocol DataProviderConvertibleType {
    associatedtype DataType
    
    func asAnyDataProvider() -> AnyDataProvider<DataType>
}