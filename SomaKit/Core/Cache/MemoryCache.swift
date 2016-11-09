//
//  MemoryCache.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

open class MemoryCache<TKey: Hashable, TData>: CacheBase<TKey, TData> {
    private let memoryStore = MemoryStore<TKey, CacheDataType>()
    private let clearOnMemoryWarning: Bool
    
    public init(lifeTimeBehavior: CacheLifeTimeBehavior = .default, clearOnMemoryWarning: Bool = false) {
        self.clearOnMemoryWarning = clearOnMemoryWarning
        
        super.init(sourceStore: memoryStore, lifeTimeBehavior: lifeTimeBehavior)
        
        if clearOnMemoryWarning {
            NotificationCenter.default.addObserver(self, selector: #selector(onMemoryWarning),
                                                             name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: UIApplication.shared)
        }
    }
    
    deinit {
        if clearOnMemoryWarning {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: UIApplication.shared)
        }
    }
    
    @objc private func onMemoryWarning() {
        memoryStore.removeAllData()
    }
}
