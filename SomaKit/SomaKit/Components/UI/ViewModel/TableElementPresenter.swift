//
//  TableElementPresenter.swift
//  SomaKit
//
//  Created by Anton on 10.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol UnsafeTableElementPresenter {
    func unsafeBindViewModel(viewModel: ViewModelType)
    func resetViewModel()
}

public protocol TableElementPresenter: UnsafeTableElementPresenter {
    associatedtype ViewModel: ViewModelType
    func bindViewModel(viewModel: ViewModel)
}

public extension UnsafeTableElementPresenter where Self: TableElementPresenter {
    public func unsafeBindViewModel(viewModel: ViewModelType) {
        guard let castedViewModel = viewModel as? ViewModel else {
            Debug.error("Unsafe table element view model binding failed: view model has wrong type \(type(of: viewModel)). Expected type \(ViewModel.self).")
            return
        }

        bindViewModel(viewModel: castedViewModel)
    }
}
