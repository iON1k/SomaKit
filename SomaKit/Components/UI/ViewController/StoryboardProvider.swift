//
//  StoryboardProvider.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public protocol StoryboardFactoryType {
    func loadStoryboard() -> UIStoryboard
}

open class StoryboardFactory: StoryboardFactoryType {
    public typealias StoryboardFactoryHandler = (Void) -> UIStoryboard
    
    fileprivate let storyboardFactoryHandler: StoryboardFactoryHandler
    
    open func loadStoryboard() -> UIStoryboard {
        return storyboardFactoryHandler()
    }
    
    public init(storyboardFactoryHandler: @escaping StoryboardFactoryHandler) {
        self.storyboardFactoryHandler = storyboardFactoryHandler
    }
    
    public convenience init(storyboardName: String, storyboardBundle: Bundle? = nil) {
        self.init() {
            return UIStoryboard(name: storyboardName, bundle: storyboardBundle)
        }
    }
}

extension UIStoryboard: StoryboardFactoryType {
    public func loadStoryboard() -> UIStoryboard {
        return self
    }
}

public protocol StoryboardViewControllerProviderType {
    static var storyboardViewControllerData: (storyboardFactory: StoryboardFactoryType, storyboardId: String) { get }
}

extension StoryboardViewControllerProviderType where Self: UIViewController {
    public static func loadFromStoryboard() -> Self {
        let storyboardData = self.storyboardViewControllerData
        let storyboard = storyboardData.storyboardFactory.loadStoryboard()
        let viewController = storyboard.instantiateViewController(withIdentifier: storyboardData.storyboardId)
        
        return Utils.unsafeCast(viewController)
    }
}
