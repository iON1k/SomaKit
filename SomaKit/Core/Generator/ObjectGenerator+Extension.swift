//
//  ObjectGenerator+Extension.swift
//  SomaKit
//
//  Created by Anton on 11.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

extension ObjectGenerator {
    public func fillPoolAsync(_ count: UInt) -> Observable<Void> {
        return Observable.deferred { () -> Observable<Void> in
            return Observable.just(())
        }
        .do { () in
            self.fillPool(count)
        }
        .subcribeOnBackgroundScheduler()
    }
}
