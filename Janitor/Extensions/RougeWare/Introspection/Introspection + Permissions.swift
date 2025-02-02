//
//  Introspection + Permissions.swift
//  Janitor
//
//  Created by The Northstar✨ System on 2024-02-10.
//

import Foundation

import Introspection
import JanitorKit
import SimpleLogging



public extension Introspection {
    enum Permission {}
}



public extension Introspection.Permission {
//    static func file(_ accessIntentKind: FileAccessIntentKind) -> File {
//        let rootUrl = URL(filePath: "/")
//        let downloadsUrl = URL.homeDirectory.appendingPathComponent("Downloads")
//        if rootUrl.startAccessingSecurityScopedResource() {
//            defer { rootUrl.stopAccessingSecurityScopedResource() }
//            return .fullFilesystem
//        }
//        else if downloadsUrl.startAccessingSecurityScopedResource() {
//            defer { downloadsUrl.stopAccessingSecurityScopedResource() }
//            return .someFiles([downloadsUrl])
//        }
//        else {
//            return .noAccess
//        }
//    }
    
    
    
    /// Determins the level of permission this process has to access the file at the given URL.
    ///
    /// The given URL must point to a local file, or else the returned value might not make sense
    ///
    /// - Parameter fileUrl: A URL to the file you want to check to see if this process can access it
    /// - Returns: A file access value describing how much access this process has to the given file
    static func fileAccess(_ fileUrl: URL) -> FileAccess {
        guard fileUrl.isFileURL else {
            return .read
        }
        
        var fileUrl = fileUrl
        
        do {
            try fileUrl.loadFromBookmarks()
        }
        catch {
            log(error: error)
        }
        
        
        guard fileUrl.startAccessingSecurityScopedResource() else {
            return .noAccess
        }
        defer { fileUrl.stopAccessingSecurityScopedResource() }
        
        if fileUrl.hasDirectoryPath {
            let uuid = UUID().uuidString
            let testFileUrl = fileUrl / ".__\(uuid).janitorTestFile"
            
            do {
                try uuid.write(to: testFileUrl, atomically: true, encoding: .utf8)
                defer { try? FileManager.default.removeItem(at: testFileUrl) }
                
                if uuid == (try String(contentsOf: testFileUrl, encoding: .utf8)) {
                    return .readWrite(canDelete: FileManager.default.isDeletableFile(atPath: testFileUrl.actualPath))
                }
            }
            catch {
                return .noAccess // Is this the best decision here?
            }
        }
        
//        if fileUrl.startAccessingSecurityScopedResource() {
//            defer { fileUrl.stopAccessingSecurityScopedResource() }
            
            let actualPath = fileUrl.actualPath
            
            return FileManager.default.isWritableFile(atPath: actualPath)
                ? .readWrite(canDelete: FileManager.default.isDeletableFile(atPath: actualPath))
                : .read
//        }
//        else {
//            return .noAccess
//        }
    }
    
    
    
//    enum File {
//        case fullFilesystem
//        case someFiles(_ allowedAccessUrls: [URL])
//        case noAccess
//    }
}



public extension Introspection.Permission {
    
    /// Describes the permissions a process currently has to access a file
    enum FileAccess: Equatable {
        
        /// The process does not have access to the file, nor files in the directory
        case noAccess
        
        /// The process can read the file (or files in the directory), but cannot modify/delete
        case read
        
        /// The process can read and modify the file, or files in the directory
        ///
        /// - Parameter canDelete: Indicates whether the process can also delete the file
        case readWrite(canDelete: Bool)
    }
}
