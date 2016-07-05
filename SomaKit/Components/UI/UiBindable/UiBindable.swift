//
//  UiBindable.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol UiBindableType {
    func onBinded<T>(observable: Observable<T>) -> Observable<T>
    func onActive<T>(observable: Observable<T>) -> Observable<T>
}

extension Observable {
    public func bindOn(uiBindable: UiBindableType) -> Observable<E> {
        return uiBindable.onBinded(self)
    }
    
    public func bindOnActive(uiBindable: UiBindableType) -> Observable<E> {
        return uiBindable.onActive(self)
    }
}