//
//  avoidUsingToolbar.swift
//  Janitor
//
//  Created by Ky on 2024-08-18.
//

import Foundation
import SwiftUI



private struct AvoidUsingToolbarKey: SwiftUI.EnvironmentKey {
    static let defaultValue = false
}



public extension EnvironmentValues {
    
    /// Whether to avoid using the toolbar for controls.
    ///
    /// When this is `false`, feel free to place controls in the toolbar. This is the default state.
    ///
    /// When this is `true`, prioritize placing controls in views you directly control instead of the toolbar.
    ///
    /// This might be `true` in situations where the toolbar is not displayed, or is full, or otherwise shouldn't have controls placed inside it
    var avoidUsingToolbar: Bool {
        get { self[AvoidUsingToolbarKey.self] }
        set { self[AvoidUsingToolbarKey.self] = newValue }
    }
}
