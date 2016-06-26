//
//  CacheManagedObject.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import CoreData

public class CacheManagedObject: NSManagedObject {
    public static let DefaultCacheKey = "cacheKey"
    
    @NSManaged var cacheKey: String?
    @NSManaged var creationTimestamp: Double
}