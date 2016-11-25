//
//  ImageFakeOperation.swift
//  SomaKit
//
//  Created by Anton on 25.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImageFakeOperation: ImageOperationWrapper {
    public typealias PerformObservableHandler = (Observable<UIImage>) -> Observable<UIImage>
    
    private let performObservableHandler: PerformObservableHandler
    
    public override func _preparePerformObservable(performObservable: Observable<UIImage>) -> Observable<UIImage> {
        return super._preparePerformObservable(performObservable: performObservableHandler(performObservable))
    }
    
    public init(originalOperation: ImageOperation, performObservableHandler: @escaping PerformObservableHandler) {
        self.performObservableHandler = performObservableHandler
        super.init(originalOperation: originalOperation)
    }
}
