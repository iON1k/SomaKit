//
//  NibProvider.swift
//  SomaKit
//
//  Created by Anton on 27.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public struct NibData {
    private let nibName: String
    private let nibBundle: NSBundle?
    
    public init(nibName: String, nibBundle: NSBundle? = nil) {
        self.nibName = nibName
        self.nibBundle = nibBundle
    }
}

public protocol NibProviderType {
    static var nibData: NibData { get }
}

extension NibProviderType {
    public static func loadNib() -> UINib {
        let nibData = self.nibData
        return UINib(nibName: nibData.nibName, bundle: nibData.nibBundle)
    }
}

extension UIView {
    public static func loadFromNib(owner: AnyObject? = nil, options: [NSObject : AnyObject]? = nil) -> Self {
        var nib: UINib?
        
        if let nibProvider = self as? NibProviderType.Type {
            nib = nibProvider.loadNib()
        } else {
            nib = UINib(nibName: Utils.typeName(self.dynamicType), bundle: nil)
        }
        
        guard let view = nib?.instantiateWithOwner(owner, options: options).first as? UIView else {
            fatalError("Nib \(nib) view loading failed")
        }
        
        return Utils.unsafeCast(view)
    }
}