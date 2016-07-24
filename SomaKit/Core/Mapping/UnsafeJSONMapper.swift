//
//  UnsafeJSONMapper.swift
//  SomaKit
//
//  Created by Anton on 24.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import ObjectMapper

public class UnsafeJSONMapper {
    private typealias MappingHandler = String -> Any
    private var mappingHandlers: [String : MappingHandler] = [:]
    
    public func registerType<TMappable: Mappable>(mappableType: TMappable.Type) {
        registerType(mappableType, mapperKey: defaultKeyForType(mappableType))
    }
    
    public func registerTypeIfNeeded<TMappable: Mappable>(mappableType: TMappable.Type) {
        let mapperKey = defaultKeyForType(mappableType)
        if mappingHandlers[mapperKey] != nil {
            return
        }
        
        registerType(mappableType, mapperKey: mapperKey)
    }
    
    public func registerType<TMappable: Mappable>(mappableType: TMappable.Type, mapperKey: String) {
        mappingHandlers[mapperKey] = { (jsonString) -> Any in
            return Mapper<TMappable>().map(jsonString)
        }
    }
    
    public func map<TObject>(jsonString: String) throws -> TObject {
        return try map(jsonString, mapperKey: defaultKeyForType(TObject.Type))
    }
    
    public func map<TObject>(jsonString: String, mapperKey: String) throws -> TObject {
        guard let mappingHandler = mappingHandlers[mapperKey] else {
            throw SomaError("UnsafeJSONStringMapper no register type with key \(mapperKey)")
        }
        
        let resultObject = mappingHandler(jsonString)
        
        if let resultObject = resultObject as? TObject {
            return resultObject
        } else {
            throw SomaError("UnsafeJSONStringMapper json mapping error:\n\(jsonString)")
        }
    }
    
    private func defaultKeyForType<TObject>(mappableType: TObject.Type) -> String {
        return Utils.typeName(mappableType)
    }
}
