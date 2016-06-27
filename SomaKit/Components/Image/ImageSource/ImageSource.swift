//
//  ImageSource.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol ImageSource: ImageSourceConvertiable {
    associatedtype KeyType: ImageLoaderKeyType
    
    func loadImage(key: KeyType) -> Observable<UIImage>
}

extension ImageSource {
    public func asAnyImageSource() -> AnyImageSource<KeyType> {
        return AnyImageSource(source: self)
    }
}