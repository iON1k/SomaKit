//
//  ContentViewModelType.swift
//  SomaKit
//
//  Created by Anton on 10.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol ContentViewModelType: ViewModelType {
    var contentState: Observable<ContentState> { get }
}

public extension ContentViewModelType {
    public var contentState: Observable<ContentState> {
        return Observable.just(.normal(isEmpty: false))
    }
}
