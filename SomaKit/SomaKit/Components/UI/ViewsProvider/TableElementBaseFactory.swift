//
//  TableElementBaseFactory.swift
//  SomaKit
//
//  Created by Anton on 19.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

open class TableElementBaseFactory: TableElementFactrory {
    public let viewModelType: ViewModelType.Type

    public let viewModelTypeId: String?

    public let elementType: UIView.Type

    public var reuseId: String {
        return Utils.typeName(elementType)
    }

    public init<TViewModel: TableElementViewModel, TElement: UIView>(viewModelType: TViewModel.Type, elementType: TElement.Type, viewModelTypeId: String?)
        where TElement: TableElementType, TViewModel == TElement.ViewModel {
            self.viewModelType = viewModelType
            self.elementType = elementType
            self.viewModelTypeId = viewModelTypeId
    }

    public func createElement(tableView: UITableView) -> UIView {
        Debug.abstractMethod()
    }

    public func registerElement(tableView: UITableView) {
        Debug.abstractMethod()
    }
}
