//
//  UiBindable.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol UiBindableType {
    func whileBinded<T>(_ observable: Observable<T>) -> Observable<T>
    func whileActive<T>(_ observable: Observable<T>) -> Observable<T>
}

extension Observable {
    public func whileBinded(_ uiBindable: UiBindableType) -> Observable<E> {
        return uiBindable.whileBinded(self)
    }
    
    public func whileActive(_ uiBindable: UiBindableType) -> Observable<E> {
        return uiBindable.whileActive(self)
    }
}
