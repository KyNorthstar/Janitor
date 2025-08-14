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
    
    @NSApplicationDelegateAdaptor
    private var appDelegate: AppDelegate
    
    private let janitorialEngine = JanitorialEngine(dryRun: true, preparing: [])
    
    @State
    private var isMenuBarIconInsertedIntoMenuBar = true
    
    
    init() {
        #if DEBUG
        LogManager.defaultChannels = [
            LogChannel.swiftPrintDefault(name: "DEBUG", severityFilter: LogSeverityFilter.allowAll)
        ]
        #endif
        log(debug: "\(Self.self) initialized")
        
        Task(priority: .high) { @MainActor [self] in
            log(verbose: "Task spawned to start janitorial engine")
            await janitorialEngine.start()
        }
    }
    
    
    var body: some Scene {
        Group {
            Window(Text(Introspection.appName), id: "main") {
                DataModelTranslationLayer()
                    .modelContainer(for: [TrackedDirectoryPersistentModel.self, WholeAppSettingsModel.self])
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
                    .onAppear {
                        NSApp.setActivationPolicy(.regular)
                        log(verbose: "Activation policy set to `.regular`")
                        Task {
                            try? await Task.sleep(for: .seconds(1))
                            let icon = NSImage(named: "Icon (2024)")
                            
                            NSApp.applicationIconImage = icon
//                            NSApplication.shared.dockTile.icon = icon
                            NSApp.dockTile.display()
                        }
                    }
                    .onDisappear {
                        NSApp.setActivationPolicy(.accessory)
                        log(verbose: "Activation policy set to `.accessory`")
                    }
            }
            .windowToolbarStyle(.unified)
            
            
            
            Settings {
                SettingsView()
                    .modelContainer(for: [TrackedDirectoryPersistentModel.self, WholeAppSettingsModel.self])
                    .environmentObject(janitorialEngine)
                    .environment(\.janitorialEngineActivityFeed, janitorialEngine.activityFeed)
            }
            
            
            MenuBarExtra(Introspection.appName, image: "MenuBarIcon", isInserted: $isMenuBarIconInsertedIntoMenuBar) {
                DataModelTranslationLayer()
                    .modelContainer(for: [TrackedDirectoryPersistentModel.self, WholeAppSettingsModel.self])
                    .environmentObject(janitorialEngine)
                    .environment(\.janitorialEngineActivityFeed, janitorialEngine.activityFeed)
                    .environment(\.avoidUsingToolbar, true)
            }
            .menuBarExtraStyle(.window)
        }
    }
}



private extension App {
    final class AppDelegate: NSObject, NSApplicationDelegate {
        func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
    }
}
