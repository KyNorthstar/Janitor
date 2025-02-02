//
//  Array + ExampleData.swift
//  Array + ExampleData
//
//  Created by Ky Leggiero on 2021-08-05.
//

extension Array: ExampleDatum where Element: ExampleData {
    static var example: [Element] {
        Element.examples
    }
}



extension Array: ExampleData where Element: ExampleData {}
