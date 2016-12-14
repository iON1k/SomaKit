//
//  ImageFilteringPlugin.swift
//  SomaKit
//
//  Created by Anton on 28.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import AlamofireImage
import RxSwift

public class ImageFilteringPlugin: ImagePluginType {
    public typealias FitlerParamsType = [String : Any]
    
    private let filterName: String
    private let filterParams: FitlerParamsType?
    
    public var pluginKey: String {
        var resultKey = filterName
        if let filterParams = filterParams {
            resultKey += filterParams.description
        }
        
        return resultKey
    }
    
    public func perform(image: UIImage) throws -> UIImage {
        guard let reusltImage = image.af_imageFiltered(withCoreImageFilter: filterName, parameters: filterParams) else {
            throw SomaError("ImageFilterPlugin failed with filter named \(filterName)")
        }

        return reusltImage
    }

    public init(name: String, params: FitlerParamsType? = nil) {
        filterName = name
        filterParams = params
    }
}


public extension ImageOperation {
    public func filter(name: String, params: ImageFilteringPlugin.FitlerParamsType? = nil) -> ImageOperation {
        return ImagePluginOperation(originalOperation: self, plugin: ImageFilteringPlugin(name: name, params: params))
    }
}
