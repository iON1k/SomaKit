//
//  ImagePlugin.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol ImagePluginType {
    func perform(image: UIImage) throws -> UIImage
    var pluginKey: String { get }
}

extension UIImage {
    public func performPlugins(plugins: [ImagePluginType]) throws -> UIImage {
        var resultImage = self
        
        for plugin in plugins {
            resultImage = try plugin.perform(image: resultImage)
        }
        
        return resultImage
    }
    
    public func performPlugins(plugins: ImagePluginType ...) throws -> UIImage {
        return try performPlugins(plugins: plugins)
    }
}
