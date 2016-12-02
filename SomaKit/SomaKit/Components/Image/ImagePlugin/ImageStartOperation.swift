//
//  ImageStartOperation.swift
//  SomaKit
//
//  Created by Anton on 25.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImageStartOperation: ImageOperation, ImageOperationPerformer {
    public override var _performer: ImageOperationPerformer {
        return self
    }
    
    public override var _cachingKey: String {
        return key
    }
    
    public func _performImageOperation(operation: ImageOperation) -> Observable<UIImage> {
        return source
            .flatMap({ (image) -> Observable<UIImage> in
                return operation._begin(image: image)
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
