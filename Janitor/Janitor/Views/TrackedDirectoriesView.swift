//
//  TrackedDirectoriesView.swift
//  Janitor
//
//  Created by Ky Leggiero on 2021-07-17.
//

import SwiftUI

import CollectionTools
import JanitorKit
import SimpleLogging



struct TrackedDirectoriesView: View {
    
    @Binding
    private var trackedDirectories: [TrackedDirectory]
    
    @State
    private var selectedDirectory: TrackedDirectory?
    
    @State
    private var _viewRefreshHack = ViewRefreshHack()
    
    
    init(_ trackedDirectories: Binding<[TrackedDirectory]>) {
        self._trackedDirectories = trackedDirectories
    }
    
    
    var body: some View {
        Group {
            if trackedDirectories.isEmpty {
                noTrackedDirectoriesView
            }
            else {
                List {
                    ForEach($trackedDirectories) { dir in
                        TrackedDirectoryView(dir, onDeleteRequested: {
                            trackedDirectories.remove(firstElementWithId: dir.wrappedValue.id)
                            _viewRefreshHack.refresh()
                        }, _viewRefreshHack: $_viewRefreshHack)
                    }
                    .onDelete {
                        self.trackedDirectories.remove(atOffsets: $0)
                        _viewRefreshHack.refresh()
                    }
                    .onMove { indices, newOffset in
                        var trackedDirectories = self.trackedDirectories
                        
                        trackedDirectories.move(fromOffsets: indices, toOffset: newOffset)
                        
                        for index in trackedDirectories.indices {
                            trackedDirectories[index].sort = index
                        }
                        
                        self.trackedDirectories = trackedDirectories
                    }
                    .animation(.easeInOut(duration: 0.2), value: trackedDirectories)
                }
                .listStyle(InsetListStyle())
                
                
                .toolbar(id: "TrackedDirectoriesView") {
                    ToolbarItem(id: "Track a new directory", placement: .primaryAction, showsByDefault: true) {
                        TrackNewDirectoryButton(trackedDirectories: $trackedDirectories,
                                                onDone: { _viewRefreshHack.refresh() })
                    }
                }
            }
        }
        .frame(minWidth: 400, idealWidth: 400, minHeight: 200, idealHeight: 300)
    }
}



private extension TrackedDirectoriesView {
    var noTrackedDirectoriesView: some View {
        VStack(spacing: 24) {

            Spacer()

            Text("Janitor tracks folders to make sure they don't get too bloated.")
                .font(.title)
            Text("Add a folder to begin:")
                .font(.title2)

            HStack {
                Spacer()

                TrackNewDirectoryButton(trackedDirectories: $trackedDirectories,
                                        onDone: { _viewRefreshHack.refresh() })

                Spacer()
            }

            Spacer()
        }
        .multilineTextAlignment(.center)
    }
}



struct TrackedDirectoriesView_Previews: PreviewProvider {
    static var previews: some View {
        TrackedDirectoriesView(.constant([
            .init(uuid: UUID(),
                  sort: 1,
                  isEnabled: true,
                  url: URL(fileURLWithPath: "/Path/To/File1"),
                  oldestAllowedAge: Age(value: 30, unit: .day),
                  largestAllowedTotalSize: DataSize(value: 1, unit: .gibibyte)),
            .init(uuid: UUID(),
                  sort: 2,
                  isEnabled: false,
                  url: URL(fileURLWithPath: "/Path/To/File2"),
                  oldestAllowedAge: Age(value: 30, unit: .day),
                  largestAllowedTotalSize: DataSize(value: 1, unit: .gibibyte)),
        ]))
    }
}
