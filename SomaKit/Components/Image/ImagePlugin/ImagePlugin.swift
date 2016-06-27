//
//  ImagePlugin.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol ImagePluginType: StringCachingKeyProvider {
    func transform(image: UIImage) throws -> UIImage
}

extension UIImage {
    public func performPlugins(plugins: [ImagePluginType]) throws -> UIImage {
        var processedImage = self
        
        for plugin in plugins {
            processedImage = try plugin.transform(processedImage)
        }
        
        return processedImage
    }
    
    public func performPlugins(plugins: ImagePluginType ...) throws -> UIImage {
        return try performPlugins(plugins)
    }
    
    public func performPluginsSafe(plugins: [ImagePluginType]) -> UIImage? {
        do {
            return try performPlugins(plugins)
        } catch let error {
            Log.log(error)
        }
        
        return nil
    }
    
    public func performPluginsSafe(plugins: ImagePluginType ...) -> UIImage? {
        return performPluginsSafe(plugins)
    }
}