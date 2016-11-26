//
//  ImageOperation.swift
//  SomaKit
//
//  Created by Anton on 25.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImageOperation: ObservableType {
    public typealias E = UIImage
    
    open var _workingObservable: Observable<UIImage> {
        Debug.abstractMethod()
    }
    
    open var _performer: ImageOperationPerformer {
        Debug.abstractMethod()
    }
    
    open var _cachingKey: String {
        Debug.abstractMethod()
    }
    
    open func internalPreparePerformerObservable(performObservable: Observable<UIImage>) -> Observable<UIImage> {
        return performObservable
    }
    
    public func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == UIImage {
        return internalPreparePerformerObservable(performObservable: _performer.performImageOperation(operation: self))
            .subscribe(observer)
    }
}
