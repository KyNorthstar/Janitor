//
//  SettingsView.swift
//  Janitor
//
//  Created by Ky Leggiero on 2021-07-17.
//

import SwiftUI

import Introspection
import JanitorKit



struct SettingsView: View {
    
    @EnvironmentObject
    public var janitorialEngine: JanitorialEngine
    
    @Environment(\.janitorialEngineActivityFeed)
    private var janitorialEngineActivityFeed
    
    
    @State
    private var engineIsActuallyRunning = EngineIsActuallyRunning(currentState: false, useThisToModifyJanitorialEngine: false)
    
    @State
    private var janitorialEngineIsStillPreparing = true
    
    
    var body: some View {
        Form {
            Toggle("Big Main \(Introspection.appName) Switch", isOn: .init {
                    engineIsActuallyRunning.currentState
                } set: { newValue in
                    engineIsActuallyRunning = .init(currentState: newValue, useThisToModifyJanitorialEngine: true)
                })
                .toggleStyle(SwitchToggleStyle())
                .disabled(janitorialEngineIsStillPreparing)
                .controlSize(.extraLarge)
        }
        .padding()
        .frame(minWidth: 360, alignment: .topLeading)
        
        
        .onChange(of: engineIsActuallyRunning, initial: true) { _, newValue in
            guard newValue.useThisToModifyJanitorialEngine else { return }
            
            Task {
                await janitorialEngine.setDryRun(!newValue.currentState)
            }
        }
        
        
        .onReceive(janitorialEngineActivityFeed.runningStateChanges) { runningState in
            let newValues: RunningStateBooleans
            
            switch runningState {
            case .preparing:
                newValues = (janitorialEngineIsStillPreparing: true,
                             engineIsActuallyRunning: false)
                
            case .dryRun:
                newValues = (janitorialEngineIsStillPreparing: false,
                             engineIsActuallyRunning: false)
                
            case .ready:
                newValues = (janitorialEngineIsStillPreparing: false,
                             engineIsActuallyRunning: true)
            }
            
            self.janitorialEngineIsStillPreparing = newValues.janitorialEngineIsStillPreparing
            self.engineIsActuallyRunning = .init(currentState: newValues.engineIsActuallyRunning, useThisToModifyJanitorialEngine: false)
        }
        
        
        .task {
            let newValues: RunningStateBooleans
            
            switch await janitorialEngine.currentRunningState {
            case .preparing:
                newValues.janitorialEngineIsStillPreparing = true
                newValues.engineIsActuallyRunning = false
                
            case .ready:
                newValues.janitorialEngineIsStillPreparing = false
                newValues.engineIsActuallyRunning = true
                
            case .dryRun:
                newValues.janitorialEngineIsStillPreparing = false
                newValues.engineIsActuallyRunning = false
            }
            
            self.janitorialEngineIsStillPreparing = newValues.janitorialEngineIsStillPreparing
            self.engineIsActuallyRunning = .init(currentState: newValues.engineIsActuallyRunning, useThisToModifyJanitorialEngine: false)
        }
    }
    
    
    
    private typealias RunningStateBooleans = (janitorialEngineIsStillPreparing: Bool, engineIsActuallyRunning: Bool)
    
    
    
    private struct EngineIsActuallyRunning: Equatable {
        let currentState: Bool
        let useThisToModifyJanitorialEngine: Bool
    }
}



extension SettingsView {
    struct Previews: PreviewProvider {
        static var previews: some View {
            SettingsView()
        }
    }
}
