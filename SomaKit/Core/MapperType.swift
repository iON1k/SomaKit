//
//  MapperType.swift
//  SomaKit
//
//  Created by Anton on 19.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public protocol MapperType {
    associatedtype SourceType
    associatedtype ResultType
    
    func map(sourceObject: SourceType) throws -> ResultType
}