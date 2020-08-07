//
//  CacheBehavior.swift
//  Persister
//
//  Created by Twig on 5/9/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

public protocol CacheBehavior {
    var expirationInterval: TimeInterval { get }
    
    func read<T: Codable>(forKey key: String) throws -> T?
    func write<T: Codable>(value: T, forKey key: String) throws
}

extension CacheBehavior {
    
    public var expirationInterval: TimeInterval {
        return 0
    }
}
