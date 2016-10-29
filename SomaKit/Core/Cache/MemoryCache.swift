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
    
    public init(lifeTimeType: CacheLifeTimeType = .forever, clearOnMemoryWarning: Bool = false) {
        self.clearOnMemoryWarning = clearOnMemoryWarning
        
        super.init(sourceStore: memoryStore, lifeTimeType: lifeTimeType)
        
        if clearOnMemoryWarning {
            NotificationCenter.default.addObserver(self, selector: #selector(onMemoryWarning),
                                                             name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: UIApplication.shared)
        }
    }
    
    public convenience init(lifeTime: CacheTimeType) {
        self.init(lifeTimeType: .value(lifeTime: lifeTime, timeGenerator: TimeHelper.absoluteTime))
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
