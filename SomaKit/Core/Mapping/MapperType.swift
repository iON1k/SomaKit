//
//  MapperType.swift
//  SomaKit
//
//  Created by Anton on 24.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol MapperType {
    associatedtype SourceType
    
    func mapToSource<TModel>(model: TModel) throws -> SourceType
    func mapToModel<TModel>(source: SourceType) throws -> TModel
}