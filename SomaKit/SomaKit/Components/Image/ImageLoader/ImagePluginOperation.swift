//
//  ImagePluginOperation.swift
//  SomaKit
//
//  Created by Anton on 25.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImagePluginOperation: ImageOperationWrapper {
    public override func _prepareCachingKey(cachingKey: String) -> String {
        return cachingKey + plugin.pluginKey
    }
    
    public override func _prepareWorkingObservable(workingObservable: Observable<UIImage>) -> Observable<UIImage> {
        return workingObservable
            .flatMap({ (image) -> Observable<UIImage> in
                return self.plugin.perform(image: image)
            })
    }

    private let plugin: ImagePluginType
    
    public init(originalOperation: ImageOperation, plugin: ImagePluginType) {
        self.plugin = plugin
        super.init(originalOperation: originalOperation)
    }
}
