//
//  StringMapperType.swift
//  SomaKit
//
//  Created by Anton on 24.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public protocol UnsafeJsonMapperType {
    func mapToString<TModel>(_ model: TModel) throws -> String
    func mapToModel<TModel>(_ string: String) throws -> TModel
}
