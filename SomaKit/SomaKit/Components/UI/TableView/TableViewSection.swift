//
//  TableViewSection.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol TableViewSectionModelType {
    var cellsViewModels: [ViewModelType] { get }
    var headerViewModel: ViewModelType? { get }
    var footerViewModel: ViewModelType? { get }
}

public struct TableViewSectionModel: TableViewSectionModelType {
    public let cellsViewModels: [ViewModelType]
    public let headerViewModel: ViewModelType?
    public let footerViewModel: ViewModelType?
    
    public init(cellsViewModels: [ViewModelType], headerViewModel: ViewModelType? = nil, footerViewModel: ViewModelType? = nil) {
        self.cellsViewModels = cellsViewModels
        self.headerViewModel = headerViewModel
        self.footerViewModel = footerViewModel
    }
}