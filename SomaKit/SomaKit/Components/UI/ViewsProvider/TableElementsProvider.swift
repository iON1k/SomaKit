//
//  TableElementsProvider.swift
//  SomaKit
//
//  Created by Anton on 10.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class TableElementsProvider: ViewsProvider<UITableView> {
    public init(elementsGenerators: [ViewGenerator]) {
        super.init(viewsGenerators: elementsGenerators)
    }

    public func cellForViewModel(_ viewModel: ViewModelType, with context: UITableView) -> UITableViewCell? {
        return viewForViewModel(viewModel, with: context) as? UITableViewCell;
    }

}

