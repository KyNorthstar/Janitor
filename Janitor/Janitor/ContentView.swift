//
//  ContentView.swift
//  Janitor
//
//  Created by Ky on 2024-03-14.
//

import SwiftUI

import Introspection
import JanitorKit



struct ContentView: View {
    
    @Binding
    var trackedDirectories: [TrackedDirectory]
    
    
    var body: some View {
        switch Introspection.Permission.file(.readWrite) {
        case .fullFilesystem,
                .someFiles(_):
            TrackedDirectoriesView($trackedDirectories)
            
        case .noAccess:
            Text("You need to let me read & delete your files if you want me to be able to read & delete your files automatically")
        }
    }
}



#Preview {
    ContentView(trackedDirectories: .example)
}
