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

public class StoryboardFactory: StoryboardFactoryType {
    public typealias StoryboardFactoryHandler = Void -> UIStoryboard
    
    private let storyboardFactoryHandler: StoryboardFactoryHandler
    
    public func loadStoryboard() -> UIStoryboard {
        return storyboardFactoryHandler()
    }
    
    public init(storyboardFactoryHandler: StoryboardFactoryHandler) {
        self.storyboardFactoryHandler = storyboardFactoryHandler
    }
    
    public convenience init(storyboardName: String, storyboardBundle: NSBundle? = nil) {
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
    public static func loadFromStoryboard(owner: AnyObject? = nil, options: [NSObject : AnyObject]? = nil) -> Self {
        let storyboardData = self.storyboardViewControllerData
        let storyboard = storyboardData.storyboardFactory.loadStoryboard()
        let viewController = storyboard.instantiateViewControllerWithIdentifier(storyboardData.storyboardId)
        
        return Utils.unsafeCast(viewController)
    }
}