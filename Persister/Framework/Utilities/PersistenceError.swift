//
//  PersistenceError.swift
//  Persister
//
//  Created by Michael Liberatore on 8/7/20.
//  Copyright © 2020 Lickability. All rights reserved.
//

import Foundation

/// A list of possible errors encountered in persistence.
public enum PersistenceError: Error {
    
    /// Cached object has reached its expiration date.
    case objectIsExpired
    
    /// The object attempting to be accessed by the given key does not exist in persistence.
    case noValidDataForKey
}
