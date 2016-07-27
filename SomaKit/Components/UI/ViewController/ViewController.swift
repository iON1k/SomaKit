//
//  ViewController.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public enum ViewControllerInstantinationType {
    case Storyboard(storyboard: UIStoryboard, identifier: String)
    case New
}

public protocol ViewControllerType {
    var instantinationType: ViewControllerInstantinationType { get }
}

extension ViewControllerType where Self: UIViewController  {
    public func createInstance() -> Self {
        switch instantinationType {
        case .New:
            return Self.init()
        case .Storyboard(let storyboard, let identifier):
            let viewController = storyboard.instantiateViewControllerWithIdentifier(identifier)
            return Utils.unsafeCast(viewController)
        }
    }
}