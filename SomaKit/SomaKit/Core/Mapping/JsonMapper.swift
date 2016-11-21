//
//  JsonMapper.swift
//  SomaKit
//
//  Created by Anton on 24.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class UnsafeJsonMapper: UnsafeJsonMapperType {
    public func mapToString<TModel>(_ model: TModel) throws -> String {
        return try UnsafeJsonMappingConverter().convertValue(model)
    }
    
    public func mapToModel<TModel>(_ string: String) throws -> TModel {
        return try UnsafeJsonMappingConverter().convertValue(string)
    }
}
