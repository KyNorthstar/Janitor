//
//  UserData.swift
//  Janitor
//
//  Created by Ky Leggiero on 2021-07-17.
//

import Foundation

import JanitorKit
import SwiftyUserDefaults



struct UserData {
    @SwiftyUserDefault(keyPath: \.trackedDirectories)
    var trackedDirectories
}
