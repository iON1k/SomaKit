//
//  StringMapperType.swift
//  SomaKit
//
//  Created by Anton on 24.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public protocol _StringMapperType {
    func mapToString<TModel>(model: TModel) throws -> String
    func mapToModel<TModel>(string: String) throws -> TModel
}

public protocol StringMapperType: _StringMapperType, MapperType {
    //Nothing
}

extension _StringMapperType where Self: MapperType {
    public typealias SourceType = String
    
    public func mapToSource<TModel>(model: TModel) throws -> String {
        return try mapToString(model)
    }
    
    public func mapToModel<TModel>(source: String) throws -> TModel {
        return try mapToModel(source)
    }
}