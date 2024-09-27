//
//  WholeAppSettingsModel.swift
//  Janitor
//
//  Created by Ky on 2024-09-27.
//

import Foundation
import SwiftData

import JanitorKit



@Model
final class WholeAppSettingsModel {
    
    var dryRun: Bool
    
    init(dryRun: Bool) {
        self.dryRun = dryRun
    }
}



extension WholeAppSettingsModel {
    static var `default`: Self {
        .init(.default)
    }
}



// MARK: - Conformance

extension WholeAppSettingsModel: Equatable {
    public static func == (lhs: WholeAppSettingsModel, rhs: WholeAppSettingsModel) -> Bool {
        lhs === rhs
        || lhs.dryRun == rhs.dryRun
    }
}



extension WholeAppSettingsModel: TransparentModel {
    var base: JanitorialEngine.Configuration { .init(self) }
}



// MARK: - Conversion

extension JanitorialEngine {
    
    func configure(with settings: WholeAppSettingsModel) async {
        await self.configure(with: .init(settings))
    }
}



extension WholeAppSettingsModel {
    convenience init(_ janitorialEngineConfig: JanitorialEngine.Configuration) {
        self.init(dryRun: janitorialEngineConfig.dryRun)
    }
}



extension JanitorialEngine.Configuration {
    init(_ settings: WholeAppSettingsModel) {
        self.init(dryRun: settings.dryRun)
    }
}
