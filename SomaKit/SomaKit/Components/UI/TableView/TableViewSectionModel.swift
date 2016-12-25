//
//  TableViewSectionModel.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public typealias TableViewSectionsModels = [TableViewSectionModel]

public struct TableViewSectionModel {
    public let cellsViewModels: [TableElementViewModel]
    public let headerViewModel: TableElementViewModel?
    public let footerViewModel: TableElementViewModel?
    
    public init(cellsViewModels: [TableElementViewModel], headerViewModel: TableElementViewModel? = nil, footerViewModel: TableElementViewModel? = nil) {
        self.cellsViewModels = cellsViewModels
        self.headerViewModel = headerViewModel
        self.footerViewModel = footerViewModel
    }
}
