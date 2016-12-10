//
//  SomaViewGenerator.swift
//  SomaKit
//
//  Created by Anton on 10.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class SomaViewGenerator<TView: UIView, TViewModel: ViewModelType, TContext>: ViewGenerator where TView: ViewModelPresenter, TView.ViewModel == TViewModel {
    public typealias GenerateHandler = (TContext) -> TView

    public var viewModelType: ViewModelType.Type {
        return TViewModel.self
    }

    public var viewType: UIView.Type {
        return TView.self
    }

    private let generateHandler: GenerateHandler

    public init(generateHandler: @escaping GenerateHandler) {
        self.generateHandler = generateHandler
    }

    public func generateView(for viewModel: ViewModelType, with context: Any) -> UIView {
        guard let castedContext = context as? TContext else {
            Debug.fatalError("SomaViewGenerator: context wrong type \(type(of: context))")
        }

        guard let castedViewModel = viewModel as? TViewModel else {
            Debug.fatalError("SomaViewGenerator: view \(TView.self) binding wrong view model type \(TViewModel.self)")
        }

        let view = generateHandler(castedContext)
        view.bindViewModel(viewModel: castedViewModel)

        return view
    }
}
