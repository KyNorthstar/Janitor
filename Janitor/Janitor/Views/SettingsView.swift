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
    private var wholeAppToggleValue = false
    
    @State
    private var justUpdatingUi = false
    
    
    var body: some View {
        Form {
            Toggle("Enable \(Introspection.appName)", isOn: $wholeAppToggleValue)
                .toggleStyle(SwitchToggleStyle())
        }
        .padding()
        .frame(minWidth: 360, alignment: .topLeading)
        .onChange(of: wholeAppToggleValue, initial: true) { _, newValue in
            guard !justUpdatingUi else { return }
            
            Task {
                await janitorialEngine.setDryRun(!newValue)
            }
        }
        .onReceive(janitorialEngineActivityFeed.onlyDryRunChanges) { dryRun in
            justUpdatingUi = true
            defer { justUpdatingUi = false }
            
            wholeAppToggleValue = !dryRun
        }
    }
}



extension SettingsView {
    struct Previews: PreviewProvider {
        static var previews: some View {
            SettingsView()
        }
    }
}
