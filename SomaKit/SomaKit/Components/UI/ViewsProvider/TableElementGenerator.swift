//
//  TableElementGenerator.swift
//  SomaKit
//
//  Created by Anton on 10.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

internal class TableElementGenerator<TView: UIView, TViewModel: ViewModelType>: SomaViewGenerator<TView, TViewModel, UITableView>
        where TView: ViewModelPresenter, TView.ViewModel == TViewModel {
    internal init(reuseId: String? = nil, dequeueHandler: @escaping (UITableView, String) -> UIView?) {
        super.init { (tableView) -> TView in
            let nornalizedReuseId = reuseId ?? Utils.typeName(TView.self)

            guard let view = dequeueHandler(tableView, nornalizedReuseId) else {
                Debug.fatalError("UITableView not register view with reuseId \(nornalizedReuseId)")
            }

            guard let castedView = view as? TView else {
                Debug.fatalError("UITableView dequeued view wrong type \(type(of: view)). Expected type \(TView.self)")
            }

            return castedView
        }
    }
}

public class TableCellGenerator<TCell: UITableViewCell, TViewModel: ViewModelType>: TableElementGenerator<TCell, TViewModel>
    where TCell: ViewModelPresenter, TCell.ViewModel == TViewModel {
    public init(reuseId: String? = nil) {
        super.init(dequeueHandler: { (tableView, reuseId) -> UIView? in
            return tableView.dequeueReusableCell(withIdentifier: reuseId)
        })
    }
}

public class TableFooterHeaderGenerator<TView: UIView, TViewModel: ViewModelType>: TableElementGenerator<TView, TViewModel>
    where TView: ViewModelPresenter, TView.ViewModel == TViewModel {
    public init(tableView: UITableView, reuseId: String? = nil) {
        super.init(dequeueHandler: { (tableView, reuseId) -> UIView? in
            return tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseId)
        })
    }
}
