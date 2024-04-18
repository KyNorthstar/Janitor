//
//  DataModelTranslationLayer.swift
//  Janitor
//
//  Created by Ky Leggiero on 2021-07-17.
//

import SwiftUI
import SwiftData

import JanitorKit



struct DataModelTranslationLayer: View {
    
    @Query(sort: \TrackedDirectoryPersistentModel.self, order: .forward)
    private var trackedDirectories: [TrackedDirectoryPersistentModel]
    
    @Environment(\.modelContext)
    private var modelContext
    
    @EnvironmentObject
    private var janitorialEngine: JanitorialEngine
    
    @State
    private var currentError: Error?
    
    
    var body: some View {
        ContentView(trackedDirectories: Binding {
            trackedDirectories.map(\.trackedDirectory)
        } set: { newValue in
            do {
                try modelContext.transaction {
                    try modelContext
                        .fetch(.init(predicate: #Predicate<TrackedDirectoryPersistentModel> { _ in true }))
                        .forEach {
                            modelContext.delete($0)
                        }
                    
                    let newModels = newValue.map(TrackedDirectoryPersistentModel.init)
                    for newModel in newModels {
                        modelContext.insert(newModel)
                    }
                }
                
                try modelContext.save()
            }
            catch {
                currentError = error
            }
        })
        .onChange(of: trackedDirectories, initial: true) { oldValue, newValue in
            Task {
                await janitorialEngine.setTrackedDirectories(newValue.map(\.trackedDirectory))
            }
        }
    }
}
