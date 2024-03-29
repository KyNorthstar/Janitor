//
//  App.swift
//  Janitor
//
//  Created by Ky Leggiero on 2021-07-17.
//

import Combine
import SwiftData
import SwiftUI

import Introspection
import JanitorKit
import SimpleLogging
import SwiftyUserDefaults



var sinks = Set<AnyCancellable>()



@main
struct App: SwiftUI.App {
    
    @StateObject
    var janitorialEngine = JanitorialEngine(dryRun: true, preparing: [])
    
//    @State
//    var trackedDirectories_cache = [TrackedDirectory]()
    
    @State
    var isMenuBarIconInsertedIntoMenuBar = true
    
    
    init() {
        #if DEBUG
        LogManager.defaultChannels = [
            LogChannel.swiftPrintDefault(name: "DEBUG", severityFilter: LogSeverityFilter.allowAll)
        ]
        #endif
        log(debug: "\(Self.self) initialized")
    }
    
    
    var body: some Scene {
        WindowGroup {
            DataModelTranslationLayer()
                .modelContainer(for: [TrackedDirectory.PersistentModel.self])
                .environmentObject(janitorialEngine)
                .task {
                    log(verbose: "Task spawned to start janitorial engine")
                    await janitorialEngine.start()
                }
                .toolbar(id: "Placeholder") {
                    // All this just to get the title bar to be thicc. Making the title bar thicc always just so it
                    // doesn't cause glitches when the user adds their first directory and the "+ Track a folder"
                    // button moves to the toolbar, making it thicc.
                    //
                    // – Ky, 2022-06-26
                    ToolbarItem(id: "empty") {
                        Spacer().hidden()
                    }
                }
//                .onChange(of: trackedDirectories_cache) { old, newTrackedDirectories in
//                    Task {
//                        await janitorialEngine.setTrackedDirectories(newTrackedDirectories)
//                        SwiftyUserDefault(keyPath: \.trackedDirectories).wrappedValue = newTrackedDirectories
//                    }
//                }
//                .onReceive(janitorialEngine.activityFeed) { activity in
//                    log(verbose: activity)
//                    switch activity {
//                    case .trackedDirectoriesDidChange(newDirectories: let newDirectories):
//                        self.trackedDirectories_cache = newDirectories
//                        
//                    case .error(_),
//                        .ready,
//                        .janitorDidStart(id: _),
//                        .janitorDidStop(id: _),
//                        .didRemoveFile,
//                        .dryRunDidChange(newValue: _):
//                        break
//                    }
//                }
        }
        .windowToolbarStyle(.unified)
        
        Settings {
            SettingsView()
        }
        
        MenuBarExtra(Introspection.appName, image: "MenuBarIcon", isInserted: $isMenuBarIconInsertedIntoMenuBar) {
            Text("Yo")
        }
    }
}



extension TrackedDirectory {
    
    @Model
    class PersistentModel {
        
        let trackedDirectory: TrackedDirectory
        
        init(_ directory: TrackedDirectory) {
            self.trackedDirectory = directory
        }
        
        
        @inline(__always)
        var hashValue: Int { trackedDirectory.hashValue }
        
        
        @inline(__always)
        func hash(into hasher: inout Hasher) {
            trackedDirectory.hash(into: &hasher)
        }
    }
    
    
    
    init(_ persistentModel: Self.PersistentModel) {
        self = persistentModel.trackedDirectory
    }
}
