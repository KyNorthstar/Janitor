//
//  ViewRefreshHack.swift
//  ViewRefreshHack
//
//  Created by Ky Leggiero on 2021-07-25.
//

import Foundation



/// This hack allows you to programmatically force-refresh a SwiftUI view, when installed as a `@State` field. Simply call its `.refresh()` method from a closure in the body's view and its internal state change will trigger the SwiftUI view to be regenerated.
public struct ViewRefreshHack {
    
    private var refresher = Bool()
    
    
    /// Call this from a closure in the body's view and its internal state change will trigger the SwiftUI view to be regenerated.
    mutating func refresh() {
        refresher.toggle()
    }
}
