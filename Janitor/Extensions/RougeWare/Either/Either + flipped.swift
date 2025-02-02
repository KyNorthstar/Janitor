//
//  Either + flipped.swift
//  Janitor
//
//  Created by Ky on 2024-10-11.
//

import Foundation

import Either



public extension Either {
    /// Returns a flipped version of this so the left becomes the right and vice-versa
    var flipped: Either<Right, Left> {
        switch self {
        case .left (let oldLeft ): return .right(oldLeft)
        case .right(let oldRight): return .left(oldRight)
        }
    }
}
