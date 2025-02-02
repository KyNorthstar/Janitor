//
//  TrackedDirectoriesView.swift
//  Janitor
//
//  Created by Ky Leggiero on 2021-07-17.
//

import SwiftUI

import CollectionTools
import Introspection
import JanitorKit
import SimpleLogging



struct TrackedDirectoriesView: View {
    
    @EnvironmentObject
    private var janitorialEngine: JanitorialEngine
    
    @Environment(\.janitorialEngineActivityFeed)
    private var janitorialEngineActivityFeed
    
    @Environment(\.avoidUsingToolbar)
    private var avoidUsingToolbar
    
    @Environment(\.openWindow)
    private var openWindow
    
    @Binding
    private var trackedDirectories: [TrackedDirectory]
    
    @State
    private var _viewRefreshHack = ViewRefreshHack()
    
    @State
    private var runningState: JanitorialEngine.RunningState? = nil
    
    
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
                        TrackedDirectoryView(
                            dir,
                            onDeleteRequested: onUserDeletedTrackedDirectory(dir),
                            _viewRefreshHack: $_viewRefreshHack,
                            onUserDoneEditing: onUserDoneEditingTrackedDirectory)
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
                    
                    if avoidUsingToolbar {
                        Button("Open in full window") {
                            openWindow(id: "main")
                            NSApp.arrangeInFront(nil)
                        }
                    }
                }
                .listStyle(InsetListStyle())
                
                
                .toolbar(id: "TrackedDirectoriesView") {
                    if case .dryRun = runningState {
                        ToolbarItem(id: "Janitor isn't running") {
                            SettingsLink {
                                Text("\(Introspection.appName) isn't running")
                                    .bold()
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    
                    if !avoidUsingToolbar {
                        ToolbarItem(id: "Open settings", showsByDefault: true) {
                            SettingsLink()
                        }
                        
                        ToolbarItem(id: "Track a new directory", placement: .primaryAction, showsByDefault: true) {
                            trackNewDirectoryButton
                        }
                    }
                }
                
                
                .onReceive(janitorialEngineActivityFeed) { activity in
                    switch activity {
                    case .janitorialEngineRunningStateDidChange(runningState: let runningState):
                        self.runningState = runningState
                        
//                    case .dryRunDidChange(dryRun: let dryRun):
//                        self.isRunning = !dryRun
                        
                    case .error, .janitorDidStart, .janitorDidStop, .didRemoveFile, .trackedDirectoriesDidChange:
                        return
                    }
                }
                
                
                .onAppear {
                    Task {
                        self.runningState = await janitorialEngine.currentRunningState
                    }
                }
                
                
                .task {
                    self.runningState = await janitorialEngine.currentRunningState
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

                trackNewDirectoryButton

                Spacer()
            }

            Spacer()
        }
        .multilineTextAlignment(.center)
    }
    
    
    var trackNewDirectoryButton: some View {
        TrackNewDirectoryButton(trackedDirectories: $trackedDirectories, onDone: onUserDoneAddingNewTrackedDirectory)
    }
    
    
    private func __basicAudit(of userDoneAction: UserDoneAction) -> ShouldAcceptUserDoneAction {
        switch userDoneAction {
        case .cancel:
            // If the user doesn't want to do anything, that's fine by us
            return .accept
            
        case .confirm(proposedChanges: let configuredTrackedDirectory):
            
            let wouldDuplicate = trackedDirectories.contains { existingDirectory in
                existingDirectory.id != configuredTrackedDirectory.id
                && existingDirectory.url == configuredTrackedDirectory.url
            }
            
            guard !wouldDuplicate else {
                return .reject(reasonPresentedToUser: "That directory is already being tracked. Maybe you meant to select another, or edit the existing one?")
            }
            
            return .accept
        }
    }
    
    
    func onUserDoneAddingNewTrackedDirectory(_ userDoneAction: UserDoneAction) -> ShouldAcceptUserDoneAction {
        let auditResult = __basicAudit(of: userDoneAction)
        
        switch auditResult {
        case .accept:
            break
            
        case .reject(reasonPresentedToUser: _):
            return auditResult
        }
        
        switch userDoneAction {
        case .confirm(proposedChanges: let trackedDirectory):
            do {
                try trackedDirectory.url.saveToBookmarks()
            }
            catch {
                return .reject(reasonPresentedToUser: error.bestDescription)
            }
            
        case .cancel:
            break
        }
        
        return .accept
    }
    
    
    func onUserDoneEditingTrackedDirectory(_ userDoneAction: UserDoneAction) -> ShouldAcceptUserDoneAction {
        defer { _viewRefreshHack.refresh() }
        
        return __basicAudit(of: userDoneAction)
    }
    
    
    func onUserDeletedTrackedDirectory(_ dir: Binding<TrackedDirectory>) -> BlindCallback {{
            trackedDirectories.remove(firstElementWithId: dir.wrappedValue.id)
            _viewRefreshHack.refresh()
    }}
    
    
    typealias UserDoneAction = TrackedDirectoryConfigurationView.UserDoneAction
    typealias ShouldAcceptUserDoneAction = TrackedDirectoryConfigurationView.ShouldAcceptUserDoneAction
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
