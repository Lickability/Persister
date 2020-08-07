//
//  CacheExpirationPolicy.swift
//  Persister
//
//  Created by Michael Liberatore on 8/7/20.
//  Copyright © 2020 Lickability. All rights reserved.
//

import Foundation

/// Determines when newly written items are considered expired.
public enum CacheExpirationPolicy {
    
    /// Items never expire.
    case never
    
    /// Items expire after the associated interval.
    case afterInterval(TimeInterval)
    
    /// Returns the date of expiration for items in the cache
    /// - Parameter referenceDate: The date from which expiration should be calculated. This should usually be the date the item was written.
    func expirationDate(from referenceDate: Date) -> Date? {
        switch self {
        case .never:
            return nil
        case let .afterInterval(interval):
            return referenceDate.addingTimeInterval(interval)
        }
    }
}
