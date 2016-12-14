//
//  ImagePluginOperation.swift
//  SomaKit
//
//  Created by Anton on 25.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImagePluginOperation: ImageOperationWrapper {
    public override var _cachingKey: String {
        return super._cachingKey + plugin.pluginKey
    }
    
    public override func _begin(image: UIImage) -> Observable<UIImage> {
        return super._begin(image: image)
            .map({ (image) -> UIImage in
                return try self.plugin.perform(image: image)
            })
            .subcribeOnBackgroundScheduler()
    }

    private let plugin: ImagePluginType
    
    public init(originalOperation: ImageOperation, plugin: ImagePluginType) {
        self.plugin = plugin
        super.init(originalOperation: originalOperation)
    }
}
