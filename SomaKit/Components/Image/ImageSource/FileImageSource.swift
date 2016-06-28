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
    
    public func loadImage(key: KeyType) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            guard let imageData = NSData(contentsOfFile: key) else {
                throw SomaError("Image data loading failed with path \(key)")
            }
            
            guard let image = UIImage(data: imageData) else {
                throw SomaError("Wrong image data with path \(key)")
            }
            
            return Observable.just(image)
        })
    }
}

extension FileImageSource {
    public func loadImageAsync(key: KeyType) -> Observable<UIImage> {
        return loadImage(key)
            .subcribeOnBackgroundScheduler()
    }
}