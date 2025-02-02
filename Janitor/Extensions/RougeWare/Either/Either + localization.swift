//
//  Either + localization.swift
//  Janitor
//
//  Created by Ky on 2024-10-11.
//

import Foundation
import SwiftUI

import Either



// MARK: - String initializers



// MARK: LocalizedStringResource

public typealias VerbatimOrLocalized = Either<String, LocalizedStringResource>



public extension String {
    init<Stringy: StringProtocol>(verbatimOrLocalized: Either<Stringy, LocalizedStringResource>) {
        switch verbatimOrLocalized {
        case .left(let left):
            self.init(left)
        case .right(let right):
            self.init(localized: right)
        }
    }
    
    
    init<Stringy: StringProtocol>(localizedOrVerbatim: Either<LocalizedStringResource, Stringy>) {
        self.init(verbatimOrLocalized: localizedOrVerbatim.flipped)
    }
}


// MARK: String.LocalizationValue

public extension String {
    init<Stringy: StringProtocol>(verbatimOrLocalized: Either<Stringy, String.LocalizationValue>) {
        switch verbatimOrLocalized {
        case .left(let left):
            self.init(left)
        case .right(let right):
            self.init(localized: right)
        }
    }
    
    
    init<Stringy: StringProtocol>(localizedOrVerbatim: Either<String.LocalizationValue, Stringy>) {
        self.init(verbatimOrLocalized: localizedOrVerbatim.flipped)
    }
}



// MARK: - LocalizedStringKey

public extension LocalizedStringKey {
    init<Stringy: StringProtocol>(verbatimOrLocalized: Either<Stringy, Self>) {
        switch verbatimOrLocalized {
        case .left(let left):
            self.init(left.description)
        case .right(let right):
            self = right
        }
    }
    
    
    init<Stringy: StringProtocol>(localizedOrVerbatim: Either<Self, Stringy>) {
        self.init(verbatimOrLocalized: localizedOrVerbatim.flipped)
    }
}



// MARK: - LocalizedStringResource

public extension LocalizedStringResource {
    init<Stringy: StringProtocol>(verbatimOrLocalized: Either<Stringy, Self>) {
        switch verbatimOrLocalized {
        case .left(let left):
            self.init(stringLiteral: left.description)
        case .right(let right):
            self = right
        }
    }
    
    
    init<Stringy: StringProtocol>(localizedOrVerbatim: Either<Self, Stringy>) {
        self.init(verbatimOrLocalized: localizedOrVerbatim.flipped)
    }
}



// MARK: - String.LocalizationValue

public extension String.LocalizationValue {
    init<Stringy: StringProtocol>(verbatimOrLocalized: Either<Stringy, Self>) {
        switch verbatimOrLocalized {
        case .left(let left):
            self.init(left.description)
        case .right(let right):
            self = right
        }
    }
    
    
    init<Stringy: StringProtocol>(localizedOrVerbatim: Either<Self, Stringy>) {
        self.init(verbatimOrLocalized: localizedOrVerbatim.flipped)
    }
}



// MARK: - Text

public extension Text {
    init(verbatimOrLocalized: Either<String, LocalizedStringKey>) {
        switch verbatimOrLocalized {
        case .left(let left):
            self.init(verbatim: left)
        case .right(let right):
            self.init(right)
        }
    }
    
    
    init(localizedOrVerbatim: Either<LocalizedStringKey, String>) {
        self.init(verbatimOrLocalized: localizedOrVerbatim.flipped)
    }
}
