//
//  TrackNewDirectoryButton.swift
//  TrackNewDirectoryButton
//
//  Created by Ky Leggiero on 2021-07-25.
//

import SwiftUI

import CollectionTools
import JanitorKit
import SimpleLogging



struct TrackNewDirectoryButton: View {
    
    @State
    private var isSelectingNewDirectoryToTrack = false
    
    @State
    private var nextTrackedDirectory: TrackedDirectory?
    
    @Binding
    private var trackedDirectories: [TrackedDirectory]
    
    private let explicitTitle: Title?
    private var automaticTitle: Title { trackedDirectories.isEmpty ? .trackADirectory : .trackAnother }
    private var title: Title { explicitTitle ?? automaticTitle }
    
    private let onDone: BlindCallback
    
    private var emphasize: Bool { trackedDirectories.isEmpty }
    
    
    public init(trackedDirectories: Binding<[TrackedDirectory]>,
                title: Title? = nil,
                onDone: @escaping BlindCallback = null)
    {
        self._trackedDirectories = trackedDirectories
        self.explicitTitle = title
        self.onDone = onDone
    }
    
    
    var body: some View {
        Button(action: { isSelectingNewDirectoryToTrack = true }) {
            Image(systemName: "plus")
            Text(title.rawValue)
                .font(emphasize ? .title3.bold() : nil)
        }
        .controlSize(.large)
        .keyboardShortcut(emphasize ? .defaultAction : nil)
        
        
        .fileImporter(isPresented: $isSelectingNewDirectoryToTrack,
                      allowedContentTypes: [.directory]) { result in
            switch result {
            case .success(let directoryUrl):
                nextTrackedDirectory = .init(
                    uuid: UUID(),
                    sort: nil,
                    isEnabled: true,
                    url: directoryUrl,
                    oldestAllowedAge: .init(value: 60, unit: .day),
                    largestAllowedTotalSize: .init(value: 5, unit: .gibibyte))
                
            case .failure(let error):
                log(error: error)
                assertionFailure()
            }
        }
        
        
        .sheet(item: $nextTrackedDirectory) { newTrackedDirectory in
            TrackedDirectoryConfigurationView(
                for: .init(
                    get: { newTrackedDirectory },
                    set: { self.trackedDirectories += $0 }
                ),
                onDone: {
                    self.nextTrackedDirectory = nil
                    onDone()
                }
            )
        }
    }
}



extension TrackNewDirectoryButton {
    enum Title: LocalizedStringKey {
        case trackADirectory = "Track a folder"
        case trackAnother = "Track another"
    }
}



struct TrackNewDirectoryButton_Previews: PreviewProvider {
    static var previews: some View {
        TrackNewDirectoryButton(trackedDirectories: .constant([]))
    }
}
