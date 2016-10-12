//
//  ImagePlugin.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol ImagePluginType {
    func transform(image: UIImage) throws -> UIImage
    var imagePluginKey: String { get }
}

extension UIImage {
    public func performPlugins(plugins: [ImagePluginType]) throws -> UIImage {
        var processedImage = self
        
        for plugin in plugins {
            processedImage = try plugin.transform(image: processedImage)
        }
        
        return processedImage
    }
    
    public func performPlugins(plugins: ImagePluginType ...) throws -> UIImage {
        return try performPlugins(plugins: plugins)
    }
    
    public func performPluginsSafe(plugins: [ImagePluginType]) -> UIImage? {
        return Utils.safe {
            return try self.performPlugins(plugins: plugins)
        }
    }
    
    public func performPluginsSafe(plugins: ImagePluginType ...) -> UIImage? {
        return performPluginsSafe(plugins: plugins)
    }
}
