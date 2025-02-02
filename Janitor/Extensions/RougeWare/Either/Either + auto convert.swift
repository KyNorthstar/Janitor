//
//  Either + auto convert.swift
//  Janitor
//
//  Created by Ky on 2024-10-12.
//

import Foundation

import Either



// MARK: - Stringy

//extension Either
//{
//    public init(extendedGraphemeClusterLiteral value: Left.ExtendedGraphemeClusterLiteralType)
//        where Left: ExpressibleByExtendedGraphemeClusterLiteral
//    {
//        self = .left(.init(extendedGraphemeClusterLiteral: value))
//    }
//    
//    public init(extendedGraphemeClusterLiteral value: Right.ExtendedGraphemeClusterLiteralType)
//        where Right: ExpressibleByExtendedGraphemeClusterLiteral
//    {
//        self = .right(.init(extendedGraphemeClusterLiteral: value))
//    }
//}
//
//
//
//extension Either
//{
//    public init(stringLiteral value: Left.StringLiteralType)
//    where Left: ExpressibleByStringLiteral
//    {
//        self = .left(.init(stringLiteral: value))
//    }
//    
//    
//    public init(stringLiteral value: Right.StringLiteralType)
//    where Right: ExpressibleByStringLiteral
//    {
//        self = .right(.init(stringLiteral: value))
//    }
//}
//
//
//
//extension Either
//{
//    public init(unicodeScalarLiteral value: Left.UnicodeScalarLiteralType)
//    where Left: ExpressibleByUnicodeScalarLiteral
//    {
//        self = .left(.init(unicodeScalarLiteral: value))
//    }
//    
//    
//    public init(unicodeScalarLiteral value: Right.UnicodeScalarLiteralType)
//    where Right: ExpressibleByUnicodeScalarLiteral
//    {
//        self = .right(.init(unicodeScalarLiteral: value))
//    }
//}



//// MARK: Right
//
//extension Either: @retroactive ExpressibleByExtendedGraphemeClusterLiteral
//where Right: ExpressibleByExtendedGraphemeClusterLiteral
//{
//    public init(extendedGraphemeClusterLiteral value: Right.ExtendedGraphemeClusterLiteralType) {
//        self = .right(.init(extendedGraphemeClusterLiteral: value))
//    }
//}
//
//
//
//extension Either: @retroactive ExpressibleByStringLiteral
//where Right: ExpressibleByStringLiteral
//{
//    public init(stringLiteral value: Right.StringLiteralType) {
//        self = .right(.init(stringLiteral: value))
//    }
//}
//
//
//
//extension Either: @retroactive ExpressibleByUnicodeScalarLiteral
//where Right: ExpressibleByUnicodeScalarLiteral
//{
//    public init(unicodeScalarLiteral value: Right.UnicodeScalarLiteralType) {
//        self = .right(.init(unicodeScalarLiteral: value))
//    }
//}
