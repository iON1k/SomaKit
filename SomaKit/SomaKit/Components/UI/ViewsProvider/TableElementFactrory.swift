//
//  TableElementFactrory.swift
//  SomaKit
//
//  Created by Anton on 19.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol TableElementFactrory {
    var viewModelType: ViewModelType.Type { get }

    var viewModelTypeId: String? { get }

    var elementType: UIView.Type { get }

    func registerElement(tableView: UITableView)

    func createElement(tableView: UITableView) -> UIView
}
