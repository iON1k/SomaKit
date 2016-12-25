//
//  TableElementsProvider.swift
//  SomaKit
//
//  Created by Anton on 10.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class TableElementsProvider {
    private let elementsFactoriesByTypeName: [String : TableElementFactrory]

    public init(elementsFactories: [TableElementFactrory]) {
        var elementsFactoriesByTypeName = [String : TableElementFactrory]()

        elementsFactories.forEach { (factory) in
            let factoryId = TableElementsProvider.generateFactoryId(for: factory.viewModelType, with: factory.viewModelTypeId)
            guard elementsFactoriesByTypeName[factoryId] == nil else {
                Log.error("TableElementsProvider: view factory with key \(factoryId) already registered")
                return
            }

            elementsFactoriesByTypeName[factoryId] = factory
        }

        self.elementsFactoriesByTypeName = elementsFactoriesByTypeName
    }

    public func registerAllFactories(with tableView: UITableView) {
        elementsFactoriesByTypeName.forEach { (_, factory) in
            factory.registerElement(tableView: tableView)
        }
    }

    public func elementView(for viewModel: TableElementViewModel, with tableView: UITableView) -> UIView? {
        return elementFactory(for: viewModel)?.createElement(tableView: tableView)
    }

    public func elementFactory(for viewModel: TableElementViewModel) -> TableElementFactrory? {
        let factoryId = TableElementsProvider.generateFactoryId(for: type(of:viewModel), with: viewModel.typeId)
        return elementsFactoriesByTypeName[factoryId]
    }

    private static func generateFactoryId(for viewModelType: ViewModelType.Type, with viewModelTypeId: String?) -> String {
        var factoryId = Utils.typeName(viewModelType)

        if let viewModelTypeId = viewModelTypeId {
            factoryId += viewModelTypeId
        }

        return factoryId
    }
}
