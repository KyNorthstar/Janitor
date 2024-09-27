//
//  DataModelTranslationLayer.swift
//  Janitor
//
//  Created by Ky Leggiero on 2021-07-17.
//

import SwiftUI
import SwiftData

import JanitorKit

import Introspection
import SimpleLogging



struct DataModelTranslationLayer: View {
    
    // Wanna use this sort, but guess what, it crashes!
    @Query//(sort: \TrackedDirectoryPersistentModel.trackedDirectory, order: .forward)
    private var trackedDirectories: [TrackedDirectoryPersistentModel]
    
    @Query
    private var wholeAppSettings: [WholeAppSettingsModel]
    
    @Environment(\.modelContext)
    private var modelContext
    
    @EnvironmentObject
    private var janitorialEngine: JanitorialEngine
    
    @State
    private var currentError: Error?
    
    
    public init() {}
    
    
    var body: some View {
        ContentView(trackedDirectories: Binding {
            trackedDirectories.map(\.trackedDirectory).sorted()
        } set: { newValues in
            do {
                try modelContext.replaceTransparentModelsOfType(newValues: newValues, forModelType: TrackedDirectoryPersistentModel.self)
            }
            catch {
                currentError = error
            }
        })
        
        
        .alert("Something's not right", presenting: $currentError) { _ in
            Button("Try to continue anyway") {
                currentError = nil
            }
            Button("Quit \(Introspection.appName)") {
                NSApp.terminate(self)
            }
        } message: { currentError in
            VStack {
                Text("I ran into a problem while trying to remember what's going on:")
                Text(currentError.localizedDescription)
            }
        }
        
        
        .onChange(of: trackedDirectories, initial: true) { oldValue, newValue in
            Task {
                await janitorialEngine.setTrackedDirectories(newValue.map(\.trackedDirectory).sorted())
            }
        }
        
        
        .onChange(of: wholeAppSettings, initial: true) { oldValue, newValue in
            
            let newValue = newValue.first
            
            Task {
                if let newValue {
                    await janitorialEngine.configure(with: newValue)
                }
                else {
                    log(error: "No app settings found. Saving default settings and starting from those")
                    
                    let settings = WholeAppSettingsModel.default
                    
                    await janitorialEngine.configure(with: settings)
                    
                    // Make sure these new settings we just made are the only ones there.
                    // There should NEVER be more than 1 "whole-app settings" saved to disk, of course
                    try modelContext
                        .fetch(.init(predicate: #Predicate<WholeAppSettingsModel> { _ in true }))
                        .forEach {
                            modelContext.delete($0)
                        }
                    
                    modelContext.insert(settings)
                }
            }
        }
        
        
        .onReceive(janitorialEngine.activityFeed) { activity in
            let oldSettings = currentSavedConfig
            
            Task {
                let newSettings = await janitorialEngine.currentConfig
                
                guard oldSettings != newSettings else { return }
                
                do {
                    try modelContext.replaceTransparentModelsOfType(newValues: [newSettings], forModelType: WholeAppSettingsModel.self)
                }
                catch {
                    currentError = error
                }
            }
        }
    }
}



extension DataModelTranslationLayer {
    var currentSavedConfig: JanitorialEngine.Configuration {
        wholeAppSettings.first.map(JanitorialEngine.Configuration.init)
        ?? .default
    }
}
