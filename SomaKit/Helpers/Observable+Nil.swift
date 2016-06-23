//
//  Observable+Nil.swift
//  SomaKit
//
//  Created by Anton on 22.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public extension Observable where Element: OptionalType {
    public func ignoreNil() -> Observable<E.Wrapped> {
        return self.filter({ (element) -> Bool in
                return element.hasValue
            })
            .map({ (element) -> E.Wrapped in
                return element.value
            })
    }
}