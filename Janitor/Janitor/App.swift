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


//-[NSApplication(NSPersistentUIRestorationSupport) _restoreWindowWithRestoration:completionHandler:] 
//Exception thrown while restoring window with identifier
//SwiftUI.ModifiedContent<
//    SwiftUI.ModifiedContent<
//        SwiftUI.ModifiedContent<
//            SwiftUI.ModifiedContent<
//                Janitor.DataModelTranslationLayer,
//                _SwiftData_SwiftUI.(unknown context at $7ffb1967b510).CustomModelContainerViewModifier
//            >,
//            SwiftUI._EnvironmentKeyWritingModifier<
//                Swift.Optional<
//                    JanitorKit.JanitorialEngine
//                >
//            >
//        >,
//        SwiftUI._EnvironmentKeyWritingModifier<
//            Combine.AnyPublisher<
//                JanitorKit.JanitorialEngine.Activity,
//                Swift.Never
//            >
//        >
//    >,
//    SwiftUI.ToolbarModifier<
//        Swift.String, SwiftUI.TupleToolbarContent<
//            SwiftUI.ToolbarItem<
//                Swift.String,
//                SwiftUI.ModifiedContent<
//                    SwiftUI.Spacer,
//                    SwiftUI._HiddenModifier
//                >
//            >
//        >
//    >
//>
//-1-AppWindow-1,
//calling completion handler with nil




@main
struct App: SwiftUI.App {
    
    private let janitorialEngine = JanitorialEngine(dryRun: false, preparing: [])
    
    @State
    private var isMenuBarIconInsertedIntoMenuBar = true
    
    
    init() {
        #if DEBUG
        LogManager.defaultChannels = [
            LogChannel.swiftPrintDefault(name: "DEBUG", severityFilter: LogSeverityFilter.allowAll)
        ]
        #endif
        log(debug: "\(Self.self) initialized")
        
        Task(priority: .high) { [self] in
            log(verbose: "Task spawned to start janitorial engine")
            await janitorialEngine.start()
        }
    }
    
    
    var body: some Scene {
        Group {
            WindowGroup {
                DataModelTranslationLayer()
                    .modelContainer(for: [TrackedDirectoryPersistentModel.self])
                    .environmentObject(janitorialEngine)
                    .environment(\.janitorialEngineActivityFeed, janitorialEngine.activityFeed)
                
                    .toolbar(id: "Placeholder") {
                        // All this just to get the title bar to be thicc. Making the title bar thicc just so it
                        // doesn't cause glitches when the user adds their first directory and the "+ Track a folder"
                        // button moves to the toolbar, which will make it thicc.
                        //
                        // – Ky, 2022-06-26
                        ToolbarItem(id: "empty") {
                            Spacer().hidden()
                        }
                    }
            }
            .windowToolbarStyle(.unified)
            
            Settings {
                SettingsView()
                    .modelContainer(for: [TrackedDirectoryPersistentModel.self])
                    .environmentObject(janitorialEngine)
                    .environment(\.janitorialEngineActivityFeed, janitorialEngine.activityFeed)
            }
            
            MenuBarExtra(Introspection.appName, image: "MenuBarIcon", isInserted: $isMenuBarIconInsertedIntoMenuBar) {
                DataModelTranslationLayer()
                    .modelContainer(for: [TrackedDirectoryPersistentModel.self])
                    .environmentObject(janitorialEngine)
                    .environment(\.janitorialEngineActivityFeed, janitorialEngine.activityFeed)
            }
            .menuBarExtraStyle(.window)
        }
    }
}



@Model
final class TrackedDirectoryPersistentModel {
    
    var trackedDirectory: TrackedDirectory
    
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



extension TrackedDirectory {
    init(_ persistentModel: TrackedDirectoryPersistentModel) {
        self = persistentModel.trackedDirectory
    }
}



extension TrackedDirectoryPersistentModel: Comparable {
    public static func < (lhs: TrackedDirectoryPersistentModel, rhs: TrackedDirectoryPersistentModel) -> Bool {
        lhs.trackedDirectory < rhs.trackedDirectory
    }
}
