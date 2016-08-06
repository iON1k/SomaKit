//
//  TableElementViewModel.swift
//  SomaKit
//
//  Created by Anton on 06.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol TableElementViewModel: ViewModelType, Equivalentable {
    //Nothing
}

extension TableElementViewModel {
    public func isEquivalent(other: Any) -> Bool {
        return false
    }
}