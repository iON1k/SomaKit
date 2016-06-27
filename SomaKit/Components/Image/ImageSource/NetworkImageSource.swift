//
//  NetworkImageSource.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift
import Alamofire
import AlamofireImage

public class NetworkImageSource: ImageSourceType {
    public typealias KeyType = String
    
    private let manager: Manager
    
    public func loadImage(key: KeyType) -> Observable<UIImage> {
        return loadImage(url: key)
    }
    
    public func loadImage(url url: URLStringConvertible) -> Observable<UIImage> {
        return Observable.create({ (observer) -> Disposable in
            let request = self.manager.request(.GET, url)
                .responseImage(completionHandler: { (response) in
                    switch response.result {
                    case .Success(let image):
                        observer.onNext(image)
                        observer.onCompleted()
                    case .Failure(let error):
                        observer.onError(error)
                    }
                })
            
            return AnonymousDisposable() {
                request.cancel()
            }
        })
    }
    
    public init(manager: Manager = Manager.sharedInstance) {
        self.manager = manager
    }
}