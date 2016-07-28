//
//  TableElementPresenter.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol TableElementPresenterType: ViewPresenterType {
    func tableElementAttributes(viewModel: ViewModelType) -> TableElementAttributes
}
