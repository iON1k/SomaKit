//
//  TableHeaderFooterFactory.swift
//  SomaKit
//
//  Created by Anton on 11.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class TableHeaderFooterFactory: TableElementBaseFactory {
    public init<TViewModel: TableElementViewModel, TView: UIView>(viewModelType: TViewModel.Type, viewType: TView.Type, viewModelTypeId: String? = nil)
        where TView: TableElementType, TViewModel == TView.ViewModel {
            super.init(viewModelType: viewModelType, elementType: viewType, viewModelTypeId: viewModelTypeId)
    }

    public override func registerElement(tableView: UITableView) {
        tableView.register(elementType, forHeaderFooterViewReuseIdentifier: reuseId)
    }

    public override func createElement(tableView: UITableView) -> UIView {
        let viewReuseId = reuseId
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: viewReuseId) else {
            Debug.fatalError("UITableView didn't registered header/footer view with reuseId \(viewReuseId)")
        }

        return view
    }
}
