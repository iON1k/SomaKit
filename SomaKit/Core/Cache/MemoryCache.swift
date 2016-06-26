//
//  MemoryCache.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class MemoryCache<TData>: MemoryStore<CacheValue<TData>> {
    public override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onMemoryWarning),
                                                         name: UIApplicationDidReceiveMemoryWarningNotification, object: UIApplication.sharedApplication())
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidReceiveMemoryWarningNotification, object: UIApplication.sharedApplication())
    }
    
    @objc private func onMemoryWarning() {
        removeAllData()
    }
}

extension MemoryCache {
    public func asCacheStore(cacheLifeTime: CacheLifeTime = .Forever) -> CacheStore<KeyType, TData> {
        return CacheStore(sourceStore: self, cacheLifeTime: cacheLifeTime)
    }
}