//
//  BundleImageSource.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

open class BundleImageSource: ImageSourceType {
    public typealias KeyType = String
    
    private let bundle: Bundle
    
    open func loadImage(_ key: KeyType) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            let bundle = self.bundle
            let image = UIImage(named: key, in: bundle, compatibleWith: nil)
            guard let resultImage = image else {
                throw SomaError("Image with name \(key) in bundle \(bundle) not found")
            }
            
            return Observable.just(resultImage)
        })
    }
    
    public init(bundle: Bundle = Bundle.main) {
        self.bundle = bundle
    }
}
