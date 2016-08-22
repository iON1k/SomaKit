//
//  ImageSource.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol ImageSourceType: ImageSourceConvertiable {
    associatedtype KeyType: StringKeyConvertiable
    
    func loadImage(key: KeyType) -> Observable<UIImage>
}

extension ImageSourceType {
    public func asImageSource() -> AnyImageSource<KeyType> {
        return AnyImageSource(source: self)
    }
}