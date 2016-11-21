//
//  ImagePlugin.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol ImagePluginType {
    func perform(image: UIImage) -> Observable<UIImage>
    var imagePluginKey: String { get }
}

extension UIImage {
    public func performPlugins(plugins: [ImagePluginType]) -> Observable<UIImage> {
        var observable = Observable.just(self)
        
        for plugin in plugins {
            observable = observable.flatMap(plugin.perform)
        }
        
        return observable
    }
    
    public func performPlugins(plugins: ImagePluginType ...) -> Observable<UIImage> {
        return performPlugins(plugins: plugins)
    }
}
