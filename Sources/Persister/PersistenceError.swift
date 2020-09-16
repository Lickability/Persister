//
//  PersistenceError.swift
//  Persister
//
//  Created by Michael Liberatore on 8/7/20.
//  Copyright © 2020 Lickability. All rights reserved.
//

import Foundation

/// Possible errors encountered in persistence.
public enum PersistenceError: Error {
        
    /// The item attempting to be accessed by the given key does not exist in persistence.
    case noValidDataForKey
    
    /// The item failed to be encoded when writing.
    /// - Parameter error: The error that occurred during encoding.
    case encodingError(_ error: Error)
}
