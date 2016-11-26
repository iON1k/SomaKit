//
//  ImageStartOperation.swift
//  SomaKit
//
//  Created by Anton on 25.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImageStartOperation: ImageOperation, ImageOperationPerformer {
    private enum Constants {
        static let defaultKey = "UnknownImage"
    }
    
    public override var _workingObservable: Observable<UIImage> {
        return Observable.just(image)
    }
    
    public override var _performer: ImageOperationPerformer {
        return self
    }
    
    public override var _cachingKey: String {
        return key
    }
    
    public func performImageOperation(operation: ImageOperation) -> Observable<UIImage> {
        return operation._workingObservable
    }
    
    private let image: UIImage
    private let key: String
    
    public init(image: UIImage, key: String? = nil) {
        self.key = key ?? Constants.defaultKey
        self.image = image
    }
}

public extension UIImage {
    public func startOperation(key: String? = nil) -> ImageStartOperation {
        return ImageStartOperation(image: self, key: key)
    }
}
