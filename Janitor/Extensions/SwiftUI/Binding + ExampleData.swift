//
//  Binding + ExampleData.swift
//  Binding + ExampleData
//
//  Created by Ky Leggiero on 2021-08-05.
//

import SwiftUI



extension Binding where Value: ExampleData {
    static var example: Binding<[Value]> {
        .constant(Value.examples)
    }
}


extension Binding where Value: Collection, Value.Element: ExampleData {
    static var example: Binding<[Value.Element]> {
        .constant(Value.Element.examples)
    }
}
