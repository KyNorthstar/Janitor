//
//  TrackedDirectoryPersistentModel.swift
//  Janitor
//
//  Created by Ky on 2024-09-27.
//

import Foundation
import SwiftData

import JanitorKit



@Model
final class TrackedDirectoryPersistentModel {
    
    var trackedDirectory: TrackedDirectory
    
    init(_ directory: TrackedDirectory) {
        self.trackedDirectory = directory
    }
}



extension TrackedDirectoryPersistentModel: Hashable {
    
    @inline(__always)
    var hashValue: Int { trackedDirectory.hashValue }
    
    
    @inline(__always)
    func hash(into hasher: inout Hasher) {
        trackedDirectory.hash(into: &hasher)
    }
}



extension TrackedDirectoryPersistentModel: TransparentModel {
    var base: TrackedDirectory { trackedDirectory }
}



extension TrackedDirectory {
    init(_ persistentModel: TrackedDirectoryPersistentModel) {
        self = persistentModel.trackedDirectory
    }
}



extension TrackedDirectoryPersistentModel: Comparable {
    public static func < (lhs: TrackedDirectoryPersistentModel, rhs: TrackedDirectoryPersistentModel) -> Bool {
        lhs.trackedDirectory < rhs.trackedDirectory
    }
}
