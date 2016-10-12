//
//  CacheManagedObject.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import CoreData

open class CacheManagedObject: NSManagedObject {
    open static let DefaultCacheKey = "cacheKey"
    
    @NSManaged var cacheKey: String?
    @NSManaged var creationTime: Double
}
