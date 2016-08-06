//
//  TableViewSection.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public struct TableViewSectionModel {
    public let cellsViewModels: [ViewModelType]
    public let headerViewModel: ViewModelType?
    public let footerViewModel: ViewModelType?
}