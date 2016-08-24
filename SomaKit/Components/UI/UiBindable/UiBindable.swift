//
//  UiBindable.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol UiBindableType {
    func whileBinded<T>(observable: Observable<T>) -> Observable<T>
    func whileActive<T>(observable: Observable<T>) -> Observable<T>
}

extension Observable {
    public func whileBinded(uiBindable: UiBindableType) -> Observable<E> {
        return uiBindable.whileBinded(self)
    }
    
    public func whileActive(uiBindable: UiBindableType) -> Observable<E> {
        return uiBindable.whileActive(self)
    }
}