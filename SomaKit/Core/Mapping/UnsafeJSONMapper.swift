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
    
    private let syncLock = SyncLock()
    
    public func registerType<TMappable: Mappable>(mappableType: TMappable.Type) {
        registerType(mappableType, mapperKey: defaultKeyForType(mappableType))
    }
    
    public func registerType<TMappable: Mappable>(mappableType: TMappable.Type, mapperKey: String) {
        syncLock.sync() {
            unsafeRegisterType(mappableType, mapperKey: mapperKey)
        }
    }
    
    public func unsafeRegisterType<TMappable: Mappable>(mappableType: TMappable.Type, mapperKey: String) {
        guard unsafeMappingHandler(mapperKey) == nil else {
            return
        }
        
        mappingHandlers[mapperKey] = { (jsonString) -> Any in
            return Mapper<TMappable>().map(jsonString)
        }
    }
    
    public func map<TResult>(jsonString: String) throws -> TResult {
        return try map(jsonString, mapperKey: defaultKeyForType(TResult.Type))
    }
    
    public func map<TResult>(jsonString: String, mapperKey: String) throws -> TResult {
        guard let mappingHandler = mappingHandler(mapperKey) else {
            throw SomaError("UnsafeJSONStringMapper no register type with key \(mapperKey)")
        }
        
        let resultObject = mappingHandler(jsonString)
        
        if let resultObject = resultObject as? TResult {
            return resultObject
        } else {
            throw SomaError("UnsafeJSONStringMapper json mapping error:\n\(jsonString)")
        }
    }
    
    private func mappingHandler(mapperKey: String) -> MappingHandler? {
        return syncLock.sync() {
            return unsafeMappingHandler(mapperKey)
        }
    }
    
    private func unsafeMappingHandler(mapperKey: String) -> MappingHandler? {
        return mappingHandlers[mapperKey]
    }
    
    private func defaultKeyForType<TResult>(mappableType: TResult.Type) -> String {
        return Utils.typeName(mappableType)
    }
}
