//
//  DiskManager.swift
//  Persister
//
//  Created by Twig on 5/10/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

public struct DiskEntry<T: Codable>: Codable {
    public let object: T
    public let expiration: Date?
}

public protocol DiskManager {
    func createDirectoryIfNecessary(directoryURL: URL) throws
    
    func write(_ data: Data, toPath path: String, expiresOn date: Date?)
    func read(atPath path: String) -> DiskEntry<Data>?
    
    func remove(atPath path: String) throws
    func removeContentsOfDirectory(at url: URL) throws
    func removeExpiredContentsOfDirectory(at url: URL) throws
}

extension FileManager: DiskManager {
    
    private struct DateHolder: Codable {
        let date: Date?
    }
    
    public func createDirectoryIfNecessary(directoryURL: URL) throws {
        try createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    public func write(_ data: Data, toPath path: String, expiresOn date: Date?) {
        createFile(atPath: path, contents: data, attributes: nil)
        
        let dateHolder = DateHolder(date: date)
        try? setExtendedAttribute(FileAttributeKey.expirationDate.rawValue, on: path, data: JSONEncoder().encode(dateHolder))
    }
    
    public func read(atPath path: String) -> DiskEntry<Data>? {
        guard let data = contents(atPath: path) else {
            return nil
        }
        
        let date: Date?
        
        if let attribute = try? extendedAttribute(FileAttributeKey.expirationDate.rawValue, on: path) {
            let dateHolder = try? JSONDecoder().decode(DateHolder.self, from: attribute)
            
            date = dateHolder?.date
        } else {
            date = nil
        }
        
        return DiskEntry(object: data, expiration: date)
    }
    
    public func remove(atPath path: String) throws {
        try removeItem(atPath: path)
    }
    
    public func removeContentsOfDirectory(at url: URL) throws {
        let contentURLs = try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        
        for url in contentURLs {
            try removeItem(at: url)
        }
    }
    
    public func removeExpiredContentsOfDirectory(at url: URL) throws {
        let contentURLs = try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        
        for path in contentURLs.map({ $0.path }) {
            if let attribute = try? extendedAttribute(FileAttributeKey.expirationDate.rawValue, on: path) {
                if let dateHolder = try? JSONDecoder().decode(DateHolder.self, from: attribute), let date = dateHolder.date {
                    if date < Date() {
                        try removeItem(atPath: path)
                    }
                }
            }
        }
    }
}

extension FileAttributeKey {
    static let expirationDate = FileAttributeKey("net.lickability.fileAttributeExpirationDate")
}

extension FileManager {
    func extendedAttribute(_ name: String, on path: String) throws -> Data {
        // Get size of attribute data
        var size = getxattr(path, name, nil, 0, 0, 0)
        if size == -1 {
            throw ExtendedAttributeError(errno: errno)
        }
        
        // Prepare buffer
        let alignment = MemoryLayout<Int8>.alignment
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
        defer {
            ptr.deallocate()
        }
        size = getxattr(path, name, ptr, size, 0, 0)
        
        return Data(bytes: ptr, count: size)
    }
    
    func setExtendedAttribute(_ name: String, on path: String, data: Data) throws {
        try data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> Void in
            guard let ptr = bytes.baseAddress else {
                return
            }
            let result = setxattr(path, name, ptr, data.count, 0, 0)
            if result == -1 {
                throw ExtendedAttributeError(errno: errno)
            }
        }
    }
}

struct ExtendedAttributeError: Error {
    let code: Int32
    let name: String
    let description: String
    
    init(errno: Int32) {
        code = errno
        switch errno {
        case EEXIST:
            name = "EEXIST"
            description = "Options contains XATTR_CREATE and the named attribute already exists."
        case ENOATTR:
            name = "ENOATTR"
            description = "GET: The extended attribute does not exist. SET: Options is set to XATTR_REPLACE and the named attribute does not exist."
        case ENOTSUP:
            name = "ENOTSUP"
            description = "The file system does not support extended attributes or has them disabled."
        case EROFS:
            name = "EROFS"
            description = "The file system is mounted read-only."
        case ERANGE:
            name = "ERANGE"
            description = "GET: Value (as indicated by size) is too small to hold the extended attribute data. SET: The data size of the attribute is out of range."
        case EPERM:
            name = "EPERM"
            description = "Attributes cannot be associated with this type of object."
        case EINVAL:
            name = "EINVAL"
            description = "Name or options is invalid."
        case EISDIR:
            name = "EISDIR"
            description = "Path or fd do not refer to a regular file and the attribute in question is only applicable to files."
        case ENOTDIR:
            name = "ENOTDIR"
            description = "A component of path is not a directory."
        case ENAMETOOLONG:
            name = "ENAMETOOLONG"
            description = "Name exceeded XATTR_MAXNAMELEN UTF-8 bytes, or a component of path exceeded NAME_MAX characters, or the entire path exceeded PATH_MAX characters."
        case EACCES:
            name = "EACCES"
            description = "Search permission is denied for a component of path or permission to set the attribute is denied."
        case ELOOP:
            name = "ELOOP"
            description = "Too many symbolic links were encountered resolving path."
        case EFAULT:
            name = "EFAULT"
            description = "Path or name points to an invalid address."
        case EIO:
            name = "EIO"
            description = "An I/O error occurred while reading from or writing to the file system."
        case E2BIG:
            name = "E2BIG"
            description = "The data size of the extended attribute is too large."
        case ENOSPC:
            name = "ENOSPC"
            description = "Not enough space left on the file system."
        default:
            name = "Unknown"
            description = "Unknown error."
        }
    }
}
