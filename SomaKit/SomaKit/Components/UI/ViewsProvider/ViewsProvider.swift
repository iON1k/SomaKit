//
//  ViewsProvider.swift
//  SomaKit
//
//  Created by Anton on 27.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol ViewGenerator {
    var viewModelType: ViewModelType.Type { get }
    var viewType: UIView.Type { get }

    func generateView(for viewModel: ViewModelType, with context: Any) -> UIView
}

public class ViewsProvider<TContext> {
    private let viewsGeneratorsByType: [String : ViewGenerator]

    public init(viewsGenerators: [ViewGenerator]) {
        var viewsGeneratorsByType = [String : ViewGenerator]()

        viewsGenerators.forEach { (viewGenerator) in
            let key = ViewsProvider.viewGeneratorKey(for: viewGenerator.viewModelType)
            guard viewsGeneratorsByType[key] == nil else {
                Log.error("ViewsProvider: view generator with key \(key) already registered")
                return
            }

            viewsGeneratorsByType[key] = viewGenerator
        }

        self.viewsGeneratorsByType = viewsGeneratorsByType
    }

    public func viewForViewModel(_ viewModel: ViewModelType, with context: TContext) -> UIView? {
        return viewGenerator(for: viewModel)?.generateView(for: viewModel, with: context)
    }

    public func viewGenerator(for viewModel: ViewModelType) -> ViewGenerator? {
        let key = ViewsProvider.viewGeneratorKey(for: type(of: viewModel))
        return viewsGeneratorsByType[key]
    }

    private static func viewGeneratorKey(for viewModelType: ViewModelType.Type) -> String {
        return Utils.typeName(viewModelType)
    }
}
