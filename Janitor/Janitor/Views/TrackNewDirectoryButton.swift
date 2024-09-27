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
    
    private let onDone: OnDone
    
    private var emphasize: Bool { trackedDirectories.isEmpty }
    
    
    public init(trackedDirectories: Binding<[TrackedDirectory]>,
                title: Title? = nil,
                onDone: @escaping OnDone)
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
                let directoryUrl = directoryUrl.standardizedFileURL
                
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
        
        
        .sheet(item: $nextTrackedDirectory) { nextTrackedDirectory in
            TrackedDirectoryConfigurationView(
                for: .init(
                    get: { nextTrackedDirectory },
                    set: { newTrackedDirectory in
                        guard !trackedDirectories.contains(where: { $0.url == newTrackedDirectory.url }) else {
                            return
                        }
                        
                        trackedDirectories += newTrackedDirectory
                    }
                ),
                style: .addNewDirectory,
                onDone: { userAction in
                    let shouldAccept = onDone(userAction)
                    
                    switch shouldAccept {
                    case .accept:
                        self.nextTrackedDirectory = nil
                        
                    case .reject(reasonPresentedToUser: _):
                        break
                    }
                    
                    return shouldAccept
                }
            )
        }
    }
    
    
    
    typealias OnDone = TrackedDirectoryConfigurationView.OnDone
}



extension TrackNewDirectoryButton {
    enum Title: LocalizedStringKey {
        case trackADirectory = "Track a folder"
        case trackAnother = "Track another"
    }
}



#Preview {
    TrackNewDirectoryButton(trackedDirectories: .constant([]), onDone: constant(.accept))
}
