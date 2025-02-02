//
//  ContentView.swift
//  Janitor
//
//  Created by Ky on 2024-03-14.
//

import SwiftUI

import Introspection
import JanitorKit



private let privacySettingsUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ApplicationData")



struct ContentView: View {
    
    @Binding
    var trackedDirectories: [TrackedDirectory]
    
    
    var body: some View {
//        switch Introspection.Permission.file(.readWrite) {
//        case .fullFilesystem,
//                .someFiles(_):
            TrackedDirectoriesView($trackedDirectories)
            
//        case .noAccess:
//            VStack {
//                Text("You need to let me read & delete your files if you want me to be able to read & delete your files automatically")
//                
//                if let privacySettingsUrl {
//                    Button("Select ")
//                    Button("Open Settings") {
//                        NSWorkspace.shared.open(privacySettingsUrl)
//                    }
//                }
//                else {
//                    Text("Go to System Settings ❯ Privacy & Security")
//                    Text("Then, select either \"Files & Folders\" or \"Full Disk Access\"")
//                }
//            }
//        }
    }
}



#Preview {
    ContentView(trackedDirectories: .example)
}
