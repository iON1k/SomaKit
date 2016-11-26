//
//  ImageFakeOperation.swift
//  SomaKit
//
//  Created by Anton on 25.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImageFakeOperation: ImageOperationWrapper {
    public typealias PerformerObservableHandler = (Observable<UIImage>) -> Observable<UIImage>
    
    private let performerObservableHandler: PerformerObservableHandler
    
    public override func _preparePerformerObservable(performObservable: Observable<UIImage>) -> Observable<UIImage> {
        return super._preparePerformerObservable(performObservable: performerObservableHandler(performObservable))
    }
    
    public init(originalOperation: ImageOperation, performerObservableHandler: @escaping PerformerObservableHandler) {
        self.performerObservableHandler = performerObservableHandler
        super.init(originalOperation: originalOperation)
    }
}


public extension ImageOperation {
    public func performWith(_ perfrormHandler: @escaping ImageFakeOperation.PerformerObservableHandler) -> ImageOperation {
        return ImageFakeOperation(originalOperation: self, performerObservableHandler: perfrormHandler)
    }
}
