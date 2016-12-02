//
//  ImageOperationWrapper.swift
//  SomaKit
//
//  Created by Anton on 25.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImageOperationWrapper: ImageOperation {
    open override var _performer: ImageOperationPerformer {
        return originalOperation._performer
    }
    
    open override var _cachingKey: String {
        return originalOperation._cachingKey
    }
    
    open override func _begin(image: UIImage) -> Observable<UIImage> {
        return originalOperation._begin(image: image)
    }
    
    private let originalOperation: ImageOperation
    
    public init(originalOperation: ImageOperation) {
        self.originalOperation = originalOperation
    }
}
