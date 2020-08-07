//
//  Persister.swift
//  Persister
//
//  Created by Twig on 5/2/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation
import UIKit

public protocol Persister {
    func write<T>(entry: DiskEntry<T>, forKey key: String) throws
    func read<T>(forKey key: String) throws -> DiskEntry<T>?
    
    func remove(forKey key: String) throws
    func removeAll() throws
    func removeExpired() throws
}
