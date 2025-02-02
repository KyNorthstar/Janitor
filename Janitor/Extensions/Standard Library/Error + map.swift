//
//  Error + map.swift
//  Janitor
//
//  Created by Ky on 2024-10-07.
//

import Foundation



/// Maps the error thrown by the `original` function to be some different type/value
///
/// - Parameters:
///   - original:    The original function, which might thrown an error of type `ThrownError`
///   - errorMapper: Converts any `ThrownError` thrown by the `original` function into a `MappedError`, which is then thrown by this function
///
/// - Throws: a `MappedError` iff the `original` function threw a `ThrownError`
public func mapError<Return, ThrownError, MappedError>
    (_ original: () throws(ThrownError) -> Return,
     errorMapper: (ThrownError) -> MappedError)
throws(MappedError) -> Return
where ThrownError: Error,
    MappedError: Error
{
//    try Result(catching: original).mapError(errorMapper).get()
    do {
        return try original()
    }
    catch {
        throw errorMapper(error)
    }
}
