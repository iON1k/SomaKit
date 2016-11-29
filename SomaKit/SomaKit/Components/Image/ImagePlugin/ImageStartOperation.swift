//
//  ImageStartOperation.swift
//  SomaKit
//
//  Created by Anton on 25.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImageStartOperation: ImageOperation, ImageOperationPerformer {
    public override var _imageSource: Observable<ImageData> {
        return source
            .map({ (image) -> ImageData in
                return ImageData(sourceImage: image, operationImage: image)
            })
    }
    
    public override var _performer: ImageOperationPerformer {
        return self
    }
    
    public override var _cachingKey: String {
        return key
    }
    
    public func performImageOperation(operation: ImageOperation) -> Observable<UIImage> {
        return operation._imageSource
            .map({ (imageData) -> UIImage in
                return imageData.operationImage
            })
    }
    
    private let source: Observable<UIImage>
    private let key: String
    
    public init(source: Observable<UIImage>, key: String? = nil) {
        self.key = key ?? String()
        self.source = source
    }
}

public extension UIImage {
    public func asImageOperation(key: String? = nil) -> ImageOperation {
        return Observable.just(self).asImageOperation()
    }
}

public extension ImageOperation {
    public func asImageOperation(key: String? = nil) -> ImageOperation {
        return self
    }
}

public extension ObservableConvertibleType where E == UIImage {
    public func asImageOperation(key: String? = nil) -> ImageOperation {
        return ImageStartOperation(source: self.asObservable(), key: key)
    }
}
