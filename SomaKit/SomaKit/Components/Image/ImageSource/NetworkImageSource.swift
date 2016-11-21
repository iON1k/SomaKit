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
    public typealias KeyType = URL
    
    private let sessionManager: SessionManager
    
    public func loadImage(_ key: KeyType) -> Observable<UIImage> {
        return Observable.create({ (observer) -> Disposable in
            let request = self.sessionManager.request(key)
                .responseImage(completionHandler: { (response) in
                    switch response.result {
                    case .success(let image):
                        observer.onNext(image)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    public init(sessionManager: SessionManager = SessionManager.default) {
        self.sessionManager = sessionManager
    }
}
