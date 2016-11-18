//
//  TableElementsProvider.swift
//  SomaKit
//
//  Created by Anton on 26.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class TableElementsProvider: ViewsProvider<UITableView> {
    public init(tableView: UITableView) {
        super.init(context: tableView)
    }
}

extension TableElementsProvider {
    public func registerTableElementGenerator<TViewModel: ViewModelType,
                                              TView: UIView>(_ elementGenerator: @escaping (TViewModel, UITableView) -> TView) where TView: TableElementPresenterType {
        _internalRegisterViewGenerator(elementGenerator)
    }
}
