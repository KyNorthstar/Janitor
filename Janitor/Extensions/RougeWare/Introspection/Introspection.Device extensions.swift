//
//  Introspection.Device extensions.swift
//  Janitor
//
//  Created by Ky on 2024-09-03.
//

import AppKit

import Introspection



public extension Introspection.Device {
    /// Attempts to find the name of this device which the user specified, like `"Tracy's iMac"`
    var userAssignedName: String? {
        Host.current().localizedName
    }
    
    
    /// Attempts to find a the generic name for this device, like `"MacBook"`, or `"Laptop"`
    var genericName: String? {
        guard modelType != .unknown else {
            return (deviceClass?.localizedStringResource).map(String.init(localized:))
                ?? Host.current().name
                ?? Host.current().names.first
        }
        
        return modelType.withoutTypeSafety()
    }
    
    
    /// Attempts to find a good name for this device, like `"Tracy's iMac"`, or `"iMac"`, or `"Desktop"`
    var name: String? {
        userAssignedName ?? genericName
    }
}



extension Introspection.Device.Class: @retroactive CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .tvBox:               "TV Box"
        case .desktop:             "Desktop"
        case .laptop:              "Laptop"
        case .tablet:              "Tablet"
        case .phone:               "Phone"
        case .portableMusicPlayer: "Media Player"
        case .watch:               "Watch"
        }
    }
}
