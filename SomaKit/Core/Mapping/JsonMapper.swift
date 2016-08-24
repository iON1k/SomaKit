//
//  JsonMapper.swift
//  SomaKit
//
//  Created by Anton on 24.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class JsonMapper: StringMapperType {
    public func mapToString<TModel>(model: TModel) throws -> String {
        return try UnsafeJsonMappingConverter().convertValue(model)
    }
    
    public func mapToModel<TModel>(string: String) throws -> TModel {
        return try UnsafeJsonMappingConverter().convertValue(string)
    }
}
