//
//  PersistenceDecoder.swift
//  Persister
//
//  Created by Twig on 5/10/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

public protocol PersistenceDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: PersistenceDecoder { }
extension PropertyListDecoder: PersistenceDecoder { }
