//
//  StoryboardFactory.swift
//  SomaKit
//
//  Created by Anton on 25.10.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

open class StoryboardFactory<VCType: RawRepresentable>: FactoryType where VCType.RawValue == String {
    public typealias Instance = UIViewController
    public typealias InstanceType = VCType
    
    private let storyboard: UIStoryboard
    
    public init(storyboard: UIStoryboard) {
        self.storyboard = storyboard
    }
    
    public convenience init(storyboardName: String, storyboardBundle: Bundle? = nil) {
        self.init(storyboard: UIStoryboard(name: storyboardName, bundle: storyboardBundle))
    }
    
    public func createInstance(type: InstanceType) -> Instance {
        return storyboard.instantiateViewController(withIdentifier: type.rawValue)
    }
}

public extension StoryboardFactory {
    public func loadViewController<TViewController: UIViewController>(type: InstanceType) -> TViewController {
        guard let resultView = createInstance(type: type) as? TViewController else {
            Debug.fatalError("StoryboardFactory factory view controller with type \(type) loading failed")
        }
        
        return resultView
    }
}
