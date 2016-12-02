//
//  UiBindable.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol UIBindableType {
    func whileBinded<TObservable: ObservableType>(_ observable: TObservable) -> Observable<TObservable.E>
    func whileActive<TObservable: ObservableType>(_ observable: TObservable) -> Observable<TObservable.E>
}

extension ObservableType {
    public func whileBinded(_ uiBindable: UIBindableType) -> Observable<E> {
        return uiBindable.whileBinded(self)
    }
    
    public func whileActive(_ uiBindable: UIBindableType) -> Observable<E> {
        return uiBindable.whileActive(self)
    }
}
