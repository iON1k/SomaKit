//
//  ImageOperationWrapper.swift
//  SomaKit
//
//  Created by Anton on 25.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImageOperationWrapper: ImageOperation {
    open override var _workingObservable: Observable<UIImage> {
        return _prepareWorkingObservable(workingObservable: originalOperation._workingObservable)
    }
    
    open override var _operationPerformer: ImageOperationPerformer {
        return originalOperation._operationPerformer
    }
    
    open override var _cachingKey: String {
        return _prepareCachingKey(cachingKey: originalOperation._cachingKey)
    }
    
    open func _prepareWorkingObservable(workingObservable: Observable<UIImage>) -> Observable<UIImage> {
        return workingObservable
    }
    
    open override func _preparePerformObservable(performObservable: Observable<UIImage>) -> Observable<UIImage> {
        return super._preparePerformObservable(performObservable:
            originalOperation._preparePerformObservable(performObservable: performObservable))
    }
    
    open func _prepareCachingKey(cachingKey: String) -> String {
        return cachingKey
    }
    
    private let originalOperation: ImageOperation
    
    public init(originalOperation: ImageOperation) {
        self.originalOperation = originalOperation
    }
}
