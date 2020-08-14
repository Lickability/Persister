//
//  CacheCapacity.swift
//  Persister
//
//  Created by Michael Liberatore on 8/7/20.
//  Copyright © 2020 Lickability. All rights reserved.
//

import Foundation

/// Determines how many items can exist in a cache.
public enum CacheCapacity {
    
    /// There is no limit to the number of items in the cache.
    case unlimited
    
    /// The number of items in the cache is limited.
    /// - Parameter numberOfItems: The limit of how many items can exist in the cache.
    case limited(numberOfItems: UInt)
}
