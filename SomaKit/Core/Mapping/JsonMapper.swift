//
//  JsonMapper.swift
//  SomaKit
//
//  Created by Anton on 24.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

open class JsonMapper: StringMapperType {
    open func mapToString<TModel>(_ model: TModel) throws -> String {
        return try UnsafeJsonMappingConverter().convertValue(model)
    }
    
    open func mapToModel<TModel>(_ string: String) throws -> TModel {
        return try UnsafeJsonMappingConverter().convertValue(string)
    }
}
