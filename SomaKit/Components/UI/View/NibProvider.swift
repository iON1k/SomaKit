//
//  NibProvider.swift
//  SomaKit
//
//  Created by Anton on 27.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol NibFactoryType {
    func loadNib() -> UINib
}

open class NibFactory: NibFactoryType {
    public typealias NibFactoryHandler = (Void) -> UINib
    
    fileprivate let nibFactoryHandler: NibFactoryHandler
    
    open func loadNib() -> UINib {
        return nibFactoryHandler()
    }
    
    public init(nibFactoryHandler: @escaping NibFactoryHandler) {
        self.nibFactoryHandler = nibFactoryHandler
    }
}

extension NibFactory {
    public convenience init(nibName: String, nibBundle: Bundle? = nil) {
        self.init() {
            return UINib(nibName: nibName, bundle: nibBundle)
        }
    }
}

extension UINib: NibFactoryType {
    public func loadNib() -> UINib {
        return self
    }
}

public protocol NibProviderType {
    static var nibFactory: NibFactoryType { get }
}

extension NibProviderType {
    public static func loadNib() -> UINib {
        return nibFactory.loadNib()
    }
}

extension NibProviderType {
    public static func loadFromNib(_ owner: Any? = nil, options: [AnyHashable: Any]? = nil) -> Self {
        let nib = loadNib()
        return Utils.unsafeCast(nib.instantiate(withOwner: owner, options: options).first)
    }
}
