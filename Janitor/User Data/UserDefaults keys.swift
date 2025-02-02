//
//  UserDefaults keys.swift
//  Janitor
//
//  Created by Ky Leggiero on 2021-07-17.
//

import Foundation

import JanitorKit
import SwiftyUserDefaults



extension DefaultsKeys {
    var trackedDirectories: DefaultsKey<[TrackedDirectory]> { .init("trackedDirectories", defaultValue: []) }
}
