//
//  MemoryCache.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class MemoryCache<TKey: Hashable, TData>: CacheBase<TKey, TData> {
    private let memoryStore = MemoryStore<TKey, CacheDataType>()
    
    public init(lifeTimeType: CacheLifeTimeType = .Forever) {
        super.init(sourceStore: memoryStore, lifeTimeType: lifeTimeType)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onMemoryWarning),
                                                         name: UIApplicationDidReceiveMemoryWarningNotification, object: UIApplication.sharedApplication())
    }
    
    public convenience init(lifeTime: CacheTimeType) {
        self.init(lifeTimeType: .Value(lifeTime: lifeTime, timeGenerator: TimeHelper.absoluteTime))
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidReceiveMemoryWarningNotification, object: UIApplication.sharedApplication())
    }
    
    @objc private func onMemoryWarning() {
        memoryStore.removeAllData()
    }
}