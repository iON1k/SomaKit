//
//  ImageFiltering.swift
//  SomaKit
//
//  Created by Anton on 28.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import AlamofireImage
import RxSwift

public extension ImagePlugins {
    public class Filtering: ImagePluginType {
        public typealias FitlerParamsType = [String : Any]
        
        private let filterName: String
        private let filterParams: FitlerParamsType?
        
        public var imagePluginKey: String {
            var resultKey = filterName
            if let filterParams = filterParams {
                resultKey += filterParams.description
            }
            
            return resultKey
        }
        
        public func perform(image: UIImage) -> Observable<UIImage> {
            return Observable.deferred({ () -> Observable<UIImage> in
                guard let reusltImage = image.af_imageFiltered(withCoreImageFilter: self.filterName, parameters: self.filterParams) else {
                    throw SomaError("ImageFilterPlugin failed with filter named \(self.filterName)")
                }
                
                return Observable.just(reusltImage)
            })
                .subcribeOnBackgroundScheduler()
        }
        
        public init(name: String, params: FitlerParamsType? = nil) {
            filterName = name
            filterParams = params
        }
    }
}
