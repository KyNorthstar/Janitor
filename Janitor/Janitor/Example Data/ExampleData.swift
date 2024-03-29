//
//  ExampleData.swift
//  ExampleData
//
//  Created by Ky Leggiero on 2021-08-01.
//

import Foundation



/// A type which can have an instance created for exasmple purposes, to demonstrate what a typeical instance might look like
internal protocol ExampleDatum {
    
    /// Some example instances of this type
    static var example: Self { get }
}


extension ExampleDatum where Self: ExampleData {
    static var examples: [Self] { [example] }
}



/// A type which can have an instance created for exasmple purposes, to demonstrate what a typeical instance might look like
internal protocol ExampleData {
    
    /// Some example instances of this type
    static var examples: [Self] { get }
}
