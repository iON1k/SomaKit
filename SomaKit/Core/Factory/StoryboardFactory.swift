//
//  StoryboardFactory.swift
//  SomaKit
//
//  Created by Anton on 25.10.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public class StoryboardFactory<ViewControllerType: RawRepresentable> where ViewControllerType.RawValue == String {
    private let storyboard: UIStoryboard
    
    public init(storyboard: UIStoryboard) {
        self.storyboard = storyboard
    }
    
    public convenience init(storyboardName: String, storyboardBundle: Bundle? = nil) {
        self.init(storyboard: UIStoryboard(name: storyboardName, bundle: storyboardBundle))
    }
    
    public func loadViewController<TViewController: UIViewController>(type: ViewControllerType) -> TViewController {
        guard let resultView = storyboard.instantiateViewController(withIdentifier: type.rawValue) as? TViewController else {
            Debug.fatalError("StoryboardFactory with storyboard \(storyboard) view controller with id \(type) loading failed")
        }
        
        return resultView
    }
}
