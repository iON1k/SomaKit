//
//  TableElementBaseFactrory.swift
//  SomaKit
//
//  Created by Anton on 10.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class TableElementBaseFactrory: TableElementFactrory {
    private let createViewHandler: (ViewModelType, UITableView) -> UIView
    private let registerHandler: (UITableView) -> Void

    public let viewModelType: ViewModelType.Type

    public let viewType: UIView.Type

    public init<TView: UIView>(viewModelType: TView.ViewModel.Type, viewType: TView.Type, registerHandler: @escaping (UITableView, String) -> Void,
                dequeueHandler: @escaping (UITableView, String) -> UIView?) where TView: ViewModelPresenter {
        let reuseId = Utils.typeName(TView.self)

        self.viewModelType = viewModelType
        self.viewType = viewType

        self.registerHandler = { tableView in
            registerHandler(tableView, reuseId)
        }

        self.createViewHandler = { viewModel, tableView in
            guard let view = dequeueHandler(tableView, reuseId) else {
                Debug.fatalError("UITableView not register view with reuseId \(reuseId)")
            }

            guard let castedView = view as? TView else {
                Debug.fatalError("UITableView dequeued view wrong type \(type(of: view)). Expected type \(TView.self)")
            }

            guard let castedViewModel = viewModel as? TView.ViewModel else {
                Debug.fatalError("TableElementBaseFactrory: view model wrong type \(type(of: viewModel)). Expected type \(TView.ViewModel.self)")
            }

            castedView.bindViewModel(viewModel: castedViewModel)

            return castedView
        }
    }

    public func createView(for viewModel: ViewModelType, with tableView: UITableView) -> UIView {
        return createViewHandler(viewModel, tableView)
    }

    public func register(in tableView: UITableView) {
        registerHandler(tableView)
    }
}
