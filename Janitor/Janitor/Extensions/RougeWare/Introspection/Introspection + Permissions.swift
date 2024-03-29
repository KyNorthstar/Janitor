//
//  Introspection + Permissions.swift
//  Janitor
//
//  Created by The Northstar✨ System on 2024-02-10.
//

import Foundation



import Introspection



public extension Introspection {
    enum Permission {}
}



public extension Introspection.Permission {
    static func file(_ accessIntentKind: FileAccessIntentKind) -> File {
        let rootUrl = URL(filePath: "/")
        let downloadsUrl = URL.homeDirectory.appendingPathComponent("Downloads")
//        do {
            // get access to open file
        if rootUrl.startAccessingSecurityScopedResource() {
            defer { rootUrl.stopAccessingSecurityScopedResource() }
            return .fullFilesystem
        }
        else if downloadsUrl.startAccessingSecurityScopedResource() {
            defer { downloadsUrl.stopAccessingSecurityScopedResource() }
            return .someFiles([downloadsUrl])
        }
        else {
            return .noAccess
        }
//        fatalError()

//        } 
//        catch {
//            // Couldn't read the file.
//            print(error.localizedDescription)
//        }

    }
    
    
    
    enum File {
        case fullFilesystem
        case someFiles(_ allowedAccessUrls: [URL])
        case noAccess
    }
}



public extension Introspection.Permission {
    enum FileAccessIntentKind {
        case read
        case readWrite
    }
}
