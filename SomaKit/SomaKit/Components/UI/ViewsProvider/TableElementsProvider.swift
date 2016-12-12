//
//  TableElementsProvider.swift
//  SomaKit
//
//  Created by Anton on 10.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol TableElementFactrory {
    var viewModelType: ViewModelType.Type { get }

    var viewType: UIView.Type { get }

    func createView(for viewModel: ViewModelType, with tableView: UITableView) -> UIView

    func register(in tableView: UITableView)
}

public class TableElementsProvider {
    private let elementsFactoriesByTypeName: [String : TableElementFactrory]
    private let tableView: UITableView

    public init(tableView: UITableView, elementsFactories: [TableElementFactrory]) {
        var elementsFactoriesByTypeName = [String : TableElementFactrory]()

        elementsFactories.forEach { (elementFactory) in
            let key = TableElementsProvider.elementFactoryKey(for: elementFactory.viewModelType)
            guard elementsFactoriesByTypeName[key] == nil else {
                Log.error("TableElementsProvider: view factory with key \(key) already registered")
                return
            }

            elementFactory.register(in: tableView)
            elementsFactoriesByTypeName[key] = elementFactory
        }

        self.elementsFactoriesByTypeName = elementsFactoriesByTypeName
        self.tableView = tableView
    }

    public func view(for viewModel: ViewModelType) -> UIView? {
        return viewFactory(for: viewModel)?.createView(for: viewModel, with: tableView)
    }

    public func viewFactory(for viewModel: ViewModelType) -> TableElementFactrory? {
        let key = TableElementsProvider.elementFactoryKey(for: type(of: viewModel))
        return elementsFactoriesByTypeName[key]
    }

    private static func elementFactoryKey(for viewModelType: ViewModelType.Type) -> String {
        return Utils.typeName(viewModelType)
    }
}
