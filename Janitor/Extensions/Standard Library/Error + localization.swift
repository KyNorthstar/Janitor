//
//  Error + localization.swift
//  Janitor
//
//  Created by Ky on 2024-10-07.
//

import Foundation



public extension Error {
    /// The best string to describe this error
    var bestDescription: String {
        (self as? LocalizedError)?.errorDescription
            ?? self.localizedDescription
    }
}
