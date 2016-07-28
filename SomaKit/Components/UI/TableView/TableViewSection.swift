//
//  TableViewSection.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class TableViewSectionModel {
    public let cellsViewModels: [ViewModelType]
    public let header: ViewModelType?
    public let footer: ViewModelType?
    
    public init(cellsViewModels: [ViewModelType], header: ViewModelType? = nil, footer: ViewModelType? = nil) {
        self.cellsViewModels = cellsViewModels
        self.header = header
        self.footer = footer
    }
}