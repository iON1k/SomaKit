//
//  FileImageSource.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class FileImageSource: ImageSourceType {
    public typealias KeyType = String
    
    private let options: NSDataReadingOptions
    
    public func loadImage(key: KeyType) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            let imageData = try NSData(contentsOfFile: key, options: self.options)
            let image = UIImage(data: imageData)
            guard let resultImage = image else {
                throw SomaError("Wrong image data with file path \(key)")
            }
            
            return Observable.just(resultImage)
        })
    }
    
    public init(options: NSDataReadingOptions = NSDataReadingOptions.DataReadingMappedIfSafe) {
        self.options = options
    }
}

extension FileImageSource {
    public func loadImageAsync(key: KeyType) -> Observable<UIImage> {
        return loadImage(key)
            .subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default))
    }
}