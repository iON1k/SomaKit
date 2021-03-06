//
//  Disposable.swift
//  SomaKit
//
//  Created by Anton on 11.10.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public extension Disposable {
    public func dispose<E>(when disposeObservable: Observable<E>) {
        _ = disposeObservable
            .take(1)
            .do(onDispose: { 
                self.dispose()
            })
            .subscribe()
    }
    
    public func dispose(whenDeallocated object: NSObject) {
        dispose(when: object.rx.deallocated)
    }
}
