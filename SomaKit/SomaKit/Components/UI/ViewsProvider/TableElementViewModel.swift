//
//  TableElementViewModel.swift
//  SomaKit
//
//  Created by Anton on 19.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol TableElementViewModel: ViewModelType {
    var typeId: String? { get }
}

public extension TableElementViewModel {
    public var viewModelIdentifier: String {
        return Self.defaultViewModelIdentifier
    }

    public static var defaultViewModelIdentifier: String {
        return Utils.typeName(type(of: self))
    }
}
