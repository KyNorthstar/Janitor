//
//  URL + security access sugar.swift
//  Janitor
//
//  Created by Ky on 2024-10-07.
//

import Foundation



public extension URL {
    
    /// Wraps safe security access for this URL in a Swifty callback with a typed thows.
    ///
    /// This provides a more-ergonomic way to access the resource at this URL (assuming it's security-scoped) than the C-style `start/stopAccessingSecurityScopedResource()` calls.
    ///
    /// This is most-appropriate when you just need to access briefly and then stop accessing. If you need to access the resource across a long and complex chain of logic and domains, then the old style might work best for you.
    ///
    /// The classic `startAccessingSecurityScopedResource()` call returns a boolean which indicates `true` for "access granted" and `false` for "access denied".
    /// This function calls the given callback if access is granted, or throws a semantic error if access is denied.
    ///
    /// - Parameter accessor: When this callback is called, you've gained access. Place all your code within this callback which accesses the resource at this URL.
    /// - Throws: A semantic error if the resource could not be accessed., or if the given callback throws an error
    func accessSecurityScopedResource<Return>(with accessor: () throws -> Return) throws(SecurityScopeAccessError) -> Return {
        guard startAccessingSecurityScopedResource() else {
            throw SecurityScopeAccessError.couldNotAccessSecurityScopedResource
        }
        defer { stopAccessingSecurityScopedResource() }
        
        do {
            return try accessor()
        }
        catch {
            throw .errorOccurredWithinAccessorCallback(subError: error)
        }
    }
    
    
    
    enum SecurityScopeAccessError: LocalizedError {
        /// Attempting to call startAccessingSecurityScopedResource() returned a `false`
        case couldNotAccessSecurityScopedResource
        
        /// In cases where the security scoped-resource was accessed within a secured callback, the callback threw some error
        case errorOccurredWithinAccessorCallback(subError: Error)
        
        public var errorDescription: String? {
            switch self {
            case .couldNotAccessSecurityScopedResource:
                String(localized: "SecurityScopeAccessError.couldNotAccessSecurityScopedResource", comment: "Attempting to call startAccessingSecurityScopedResource() returned a `false`")
                
            case .errorOccurredWithinAccessorCallback(subError: let subError):
                (subError as? LocalizedError)?.errorDescription
                ?? subError.localizedDescription
            }
        }
    }
}
