//
//  ForEach + ClosedRange.swift
//  Janitor
//
//  Created by Ky on 2024-09-26.
//

import Foundation
import SwiftUI



@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ForEach where Data == ClosedRange<Int>, ID == Data.Element, Content : View {

    /// Creates an instance that computes views on demand over a given constant constant range.
    ///
    /// The instance only reads the initial value of the provided `data` and doesn't need to identify views across updates. To compute views on demand over a dynamic range, use ``ForEach/init(_:id:content:)``.
    ///
    /// - Parameters:
    ///   - data:    A constant clsoed range.
    ///   - content: The view builder that creates views dynamically.
    public init(_ data: ClosedRange<Int>, @ViewBuilder content: @escaping (Int) -> Content) {
        self.init(data, id: \.self, content: content)
    }
}
