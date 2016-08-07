//
//  Variable+Extension.swift
//  SomaKit
//
//  Created by Anton on 07.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxCocoa
import RxSwift

infix operator <= { associativity left precedence 90 }
func <= <TResult>(variable: Variable<TResult>, newValue: TResult) -> Void {
    variable.value = newValue
}