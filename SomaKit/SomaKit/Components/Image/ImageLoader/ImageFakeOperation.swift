//
//  ImageFakeOperation.swift
//  SomaKit
//
//  Created by Anton on 25.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImageFakeOperation: ImageOperationWrapper, ImageOperationPerformer {
    public typealias PerformerHandler = (Observable<UIImage>) -> Observable<UIImage>
    
    private let performerHandler: PerformerHandler
    
    public override var _performer: ImageOperationPerformer {
        return self
    }
    
    public func _performImageOperation(operation: ImageOperation) -> Observable<UIImage> {
        return performerHandler(super._performer._performImageOperation(operation: operation))
    }
    
    public init(originalOperation: ImageOperation, performerHandler: @escaping PerformerHandler) {
        self.performerHandler = performerHandler
        super.init(originalOperation: originalOperation)
    }
}


public extension ImageOperation {
    public func performWith(_ performerHandler: @escaping ImageFakeOperation.PerformerHandler) -> ImageOperation {
        return ImageFakeOperation(originalOperation: self, performerHandler: performerHandler)
    }
}
