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
    
    public func loadImage(_ key: KeyType) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            guard let imageURL = URL(string: key) else {
                throw SomaError("Image data loading failed with path \(key)")
            }
            
            let imageData = try Data(contentsOf: imageURL)
            
            guard let image = UIImage(data: imageData) else {
                throw SomaError("Wrong image data with path \(key)")
            }
            
            return Observable.just(image)
        })
    }
}

extension FileImageSource {
    public func loadImageInBackground(_ key: KeyType) -> Observable<UIImage> {
        return loadImage(key)
            .subcribeOnBackgroundScheduler()
    }
}
