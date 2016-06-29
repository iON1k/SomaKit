//
//  ImageFiltering.swift
//  SomaKit
//
//  Created by Anton on 28.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import AlamofireImage

public class ImageFiltering: ImagePluginType {
    public typealias FitlerParamsType = [String : StringKeyConvertiable]

    private let filterName: String
    private let filterParams: FitlerParamsType?
    
    public var stringCachingKey: String {
        var resultKey = filterName
        if let filterParams = filterParams {
            resultKey += filterParams.stringKey
        }
        
        return resultKey
    }
    
    public func transform(image: UIImage) throws -> UIImage {
        let params = try filterParams?.mapValues { (value) throws -> AnyObject in
            guard let newValue = value as? AnyObject else {
                throw SomaError("ImageFilterPlugin parameter \(value) wrong type.")
            }
            
            return newValue
        }
        
        guard let reusltImage = image.af_imageWithAppliedCoreImageFilter(filterName, filterParameters: params) else {
            throw SomaError("ImageFilterPlugin failed with filter named \(filterName)")
        }
        
        return reusltImage
    }
    
    public init(name: String, params: FitlerParamsType? = nil) {
        filterName = name
        filterParams = params
    }
}
