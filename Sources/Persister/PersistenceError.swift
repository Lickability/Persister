//
//  PersistenceError.swift
//  Persister
//
//  Created by Michael Liberatore on 8/7/20.
//  Copyright © 2020 Lickability. All rights reserved.
//

import Foundation

/// Possible errors encountered in persistence.
public enum PersistenceError: LocalizedError {
    
    // MARK: - PersistenceError
    
    /// The item attempting to be accessed by the given key does not exist in persistence.
    case noValidDataForKey
    
    /// The item failed to be encoded when writing.
    /// - Parameter error: The error that occurred during encoding.
    case encodingError(_ error: Error)
    
    /// The item failed to be decoded when read.
    /// - Parameter error: The error that occurred during decoding.
    case decodingError(_ error: Error)
    
    // MARK : - LocalizedError
    
    public var errorDescription: String? {
        switch self {
        case .noValidDataForKey:
            return NSLocalizedString("Item Not Found", comment: "An error title that is presented when an item is unable to be found.")
        case .encodingError:
            return NSLocalizedString("Unable to Save Item", comment: "An error title that is presented when an item is unable to be saved.")
        case .decodingError:
            return NSLocalizedString("Unable to Load Item", comment: "An error title that is presented when an item is unable to be read.")
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .noValidDataForKey:
            return NSLocalizedString("The requested item does not exist.", comment: "A failure reason for when there is no data available for a specified key.")
        case .encodingError:
            return NSLocalizedString("The item could not be saved.", comment: "A failure reason for when the item could not be saved.")
        case .decodingError:
            return NSLocalizedString("The item could not be loaded.", comment: "A failure reason for when the item could not be loaded.")
        }
    }
    
    public var recoverySuggestion: String? {
        return nil
    }
}
