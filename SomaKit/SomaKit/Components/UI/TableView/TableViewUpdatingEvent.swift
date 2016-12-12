//
//  TableViewUpdatingEvent.swift
//  SomaKit
//
//  Created by Anton on 12.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class TableViewUpdatingEvent {
    public typealias UpdatingHandler = (UITableView) -> Void

    public let sectionsModels: [TableViewSectionModel]
    public let updatingHandler: UpdatingHandler

    public init(sectionsModels: [TableViewSectionModel], updatingHandler: @escaping UpdatingHandler = TableViewUpdatingEvent.defaultUpdatingHandler) {
        self.sectionsModels = sectionsModels
        self.updatingHandler = updatingHandler
    }

    public static func defaultUpdatingHandler(tableView: UITableView) {
        tableView.reloadData()
    }
}
