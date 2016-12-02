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
    
    open var _performer: ImageOperationPerformer {
        Debug.abstractMethod()
    }
    
    open var _cachingKey: String {
        return String()
    }
    
    open func _begin(image: UIImage) -> Observable<UIImage> {
        return Observable.just(image)
    }
    
    public func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == UIImage {
        return _performer._performImageOperation(operation: self).subscribe(observer)
    }
}
