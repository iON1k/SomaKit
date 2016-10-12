//
//  ImageFiltering.swift
//  SomaKit
//
//  Created by Anton on 28.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import AlamofireImage

open class ImageFiltering: ImagePluginType {
    public typealias FitlerParamsType = [String : StringKeyConvertiable]

    fileprivate let filterName: String
    fileprivate let filterParams: FitlerParamsType?
    
    open var imagePluginKey: String {
        var resultKey = filterName
        if let filterParams = filterParams {
            resultKey += filterParams.stringKey
        }
        
        return resultKey
    }
    
    open func transform(image: UIImage) throws -> UIImage {
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
