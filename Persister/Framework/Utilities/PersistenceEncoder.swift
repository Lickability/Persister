//
//  PersistenceEncoder.swift
//  Persister
//
//  Created by Twig on 5/10/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

public protocol PersistenceEncoder {
    func encode<T: Encodable>(_ value: T) throws -> Data
}

extension JSONEncoder: PersistenceEncoder { }
extension PropertyListEncoder: PersistenceEncoder { }
