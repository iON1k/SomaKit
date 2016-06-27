//
//  BundleImageSource.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class BundleImageSource: ImageSourceType {
    public typealias KeyType = String
    
    private let bundle: NSBundle
    
    public func loadImage(key: KeyType) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            let bundle = self.bundle
            let image = UIImage(named: key, inBundle: bundle, compatibleWithTraitCollection: nil)
            guard let resultImage = image else {
                throw SomaError("Image with name \(key) in bundle \(bundle) not found")
            }
            
            return Observable.just(resultImage)
        })
    }
    
    public init(bundle: NSBundle = NSBundle.mainBundle()) {
        self.bundle = bundle
    }
}