//
//  ViewModelPresenter.swift
//  SomaKit
//
//  Created by Anton on 10.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol ViewModelPresenter {
    associatedtype ViewModel: ViewModelType
    func bindViewModel(viewModel: ViewModel)
}
