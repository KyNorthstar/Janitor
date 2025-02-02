//
//  TrackedDirectoryConfigurationView.swift
//  Janitor
//
//  Created by Ky Leggiero on 2021-07-19.
//

import SwiftUI

import Either
import FunctionTools
import SimpleLogging
import Introspection
import JanitorKit



struct TrackedDirectoryConfigurationView: View {
    
    @State
    private var workingTrackedDirectory: TrackedDirectory
    
    @Binding
    private var inoutTrackedDirectory: TrackedDirectory
    
    @State
    private var trackedDirectoryWasRejectedReason: Either<String, LocalizedStringKey>? = nil
    
    @State
    private var isSelectingNewDirectoryToTrack = false
    
    @State
    private var userDefinitelyDidConsent = false
    
    private let style: Style
    
    private let onDone: OnDone
    
    
    /// Creates a configuration view for a tracked directory
    /// 
    /// - Parameters:
    ///   - trackedDirectory:             The directory to configure. In the ideal path where the user makes changes and saves them, this is automatically set to reflect those changes.
    ///   - style:                        Determines some aspects of the appearance & behavior of this config view
    ///   - onDone:                       Called when the user dismisses this configuration view.
    ///                                   See the documentation for its parameter and return for specific behavior & expectations.
    init(for trackedDirectory: Binding<TrackedDirectory>,
         style: Style,
         onDone: @escaping OnDone)
    {
        self._inoutTrackedDirectory = trackedDirectory
        self._workingTrackedDirectory = State(initialValue: trackedDirectory.wrappedValue)
        self.style = style
        self.onDone = onDone
    }
    
    
    var body: some View {
        VStack {
            configurationArea
                .padding()
            
            Divider()
            
            dialogControlsArea
                .padding([.horizontal, .bottom])
        }
        .tint(accentColorOverride)
        .accentColor(accentColorOverride)
        
        .frame(idealWidth: 480, maxWidth: 640)
        .fixedSize()
        
//        .trackedDirectoryPicker(isPresented: <#T##Binding<Bool>#>, onDone: <#T##(UserDonePickingTrackedDirectoryAction) -> ShouldAcceptUserDonePickingTrackedDirectoryAction#>)
    }
    
    
    var configurationArea: some View {
        VStack {
            HStack(alignment: .top) {
                Button(action: { isSelectingNewDirectoryToTrack = true }) {
                    DecorativePathView(workingTrackedDirectory.url)
                }
                .buttonStyle(.link)
                .padding(.bottom)
                
                Spacer(minLength: 24)
                
                Toggle("Automatically clean this directory", isOn: $workingTrackedDirectory.isEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: accentColorOverride ?? .toggle))
                    .labelsHidden()
            }
            
            Form {
                MeasurementPicker("Oldest Allowed Age",
                                  selection: $workingTrackedDirectory.oldestAllowedAge,
                                  valueRange: Age(value: 1, unit: .minute) ... Age(value: 50, unit: .year))
                .fixedSize()
                
                Spacer().fixedSize()
                
                MeasurementPicker("Largest Combined Size",
                                  selection: $workingTrackedDirectory.largestAllowedTotalSize,
                                  valueRange: DataSize(value: 56, unit: .kilobyte) ... DataSize(value: 1, unit: .exbibyte))
                .fixedSize()
            }
        }
    }
    
    
    var dialogControlsArea: some View {
        VStack {
            AutoDeleteDangerConsentPanel(
                workingTrackedDirectory: self.workingTrackedDirectory,
                userDefinitelyDidConsent: $userDefinitelyDidConsent)?
                .transition(.move(edge: .top).combined(with: .opacity).animation(.bouncy))
            
            HStack(alignment: .lastTextBaseline) {
                Spacer()
                
                Button("Cancel", role: .cancel, action: { _ = onDone(.cancel) })
                //                .keyboardShortcut(.cancelAction)
                
                Button(confirmButtonTitle, role: confirmButtonRole, action: {
                    let acceptance = onDone(.confirm(proposedChanges: workingTrackedDirectory))
                    
                    switch acceptance {
                    case .accept:
                        inoutTrackedDirectory = workingTrackedDirectory
                        
                    case .reject(reasonPresentedToUser: let reasonPresentedToUser):
                        trackedDirectoryWasRejectedReason = reasonPresentedToUser
                    }
                    
                })
                .buttonStyle(.borderedProminent)
                .buttonRepeatBehavior(.disabled)
                .keyboardShortcut(.defaultAction)
                .disabled(!confirmButtonAllowUserInteraction)
            }
            .controlSize(.large)
        }
    }
    
    
    
    /// The type of callback called when the user is done with this config view
    typealias OnDone = (UserDoneAction) -> ShouldAcceptUserDoneAction
    
    
    
    /// An action the user took when they were done this config
    enum UserDoneAction {
        
        /// The user wants to close the config without changes.
        ///
        /// If this is passed, any returned acceptance will be ignored
        case cancel
        
        /// The user wants to commit the changes they made in this config
        /// - Parameter proposedChanges: The changes the user has made and wants to commit.
        ///                              **DO NOT USE THESE** to update anything;
        ///                              **ONLY VALIDATE** whether these changes are acceptable and return your decision using a ``ShouldAcceptUserDoneAction`` value.
        case confirm(proposedChanges: TrackedDirectory)
    }
    
    
    
    /// After the user has taken action to say they's done with this config, one of these must be returned back to them
    enum ShouldAcceptUserDoneAction {
        
        /// The user's changes are accepted.
        ///
        /// If you return this, the tracked directory binding is set to the new value.
        /// If there is anything else that must be done other than setting that binding, you must then do that where appropriate.
        case accept
        
        /// The user's changes aren't acceptable; they're rejected.
        ///
        /// If this is returned, the config will remain where it is, giving the user a chance to make the config acceptable or cancel configuration altogether.
        ///
        /// - Parameter reasonPresentedToUser: This will be directly presented to the user, as an explanation for why their config was rejected
        case reject(reasonPresentedToUser: Either<String, LocalizedStringKey>)
        
        
        @inline(__always)
        static func reject(reasonPresentedToUser: LocalizedStringKey) -> Self {
            .reject(reasonPresentedToUser: .right(reasonPresentedToUser))
        }
        
        
        @inline(__always)
        static func reject(reasonPresentedToUser: String) -> Self {
            .reject(reasonPresentedToUser: .left(reasonPresentedToUser))
        }
    }
    
    
    
    /// Determines the appearance & behvior of a trcked directory config view
    enum Style {
        
        /// An existing directory is being reconfigured
        case updateExistingDirectory
        
        /// A new directory is being added and given its initial configuration
        case addNewDirectory
    }
}



private extension TrackedDirectoryConfigurationView {
    
    var confirmButtonTitle: LocalizedStringKey {
        switch confirmButtonKind {
        case .followStyle(.updateExistingDirectory): "Update"
        case .followStyle(.addNewDirectory):         "Start Tracking"
        case .trackRoot:                             "Automatically Delete Anything On This \(Introspection.Device.current.deviceClass?.localizedStringResource ?? "Mac")"
        }
    }
    
    
    var confirmButtonRole: ButtonRole? {
        switch confirmButtonKind {
        case .followStyle(_):
            return nil
        case .trackRoot:
            return .destructive
        }
    }
    
    
    var accentColorOverride: Color? {
        switch confirmButtonKind {
        case .followStyle(_):
            return nil
            
        case .trackRoot:
            return .red
        }
    }
    
    
    var confirmButtonAllowUserInteraction: Bool {
        if workingTrackedDirectory.url.wouldBeDangerousToTrack {
            userDefinitelyDidConsent
        }
        else {
            true
        }
    }
    
    
    private var confirmButtonKind: ConfirmButtonKind {
        if wouldTrackWholeMachine {
            return .trackRoot
        }
        else {
            return .followStyle(style)
        }
    }
    
    
    var wouldTrackWholeMachine: Bool {
        workingTrackedDirectory.url.isRoot
    }
    
    
    private enum ConfirmButtonKind {
        case followStyle(Style)
        case trackRoot
    }
}



#Preview("Downloads") {
    TrackedDirectoryConfigurationView(
        for: .constant(
            TrackedDirectory(
                uuid: UUID(),
                sort: nil,
                isEnabled: true,
                url: URL(fileURLWithPath: "\(NSHomeDirectory())/Downloads"),
                oldestAllowedAge: Age(value: 30, unit: .day),
                largestAllowedTotalSize: DataSize(value: 30, unit: .gibibyte)
            )
        ),
        style: .addNewDirectory,
        onDone: constant(.reject(reasonPresentedToUser: "This is a demo"))
    )
}

#Preview("Root") {
    TrackedDirectoryConfigurationView(
        for: .constant(
            TrackedDirectory(
                uuid: UUID(),
                sort: nil,
                isEnabled: true,
                url: URL(fileURLWithPath: "/"),
                oldestAllowedAge: Age(value: 30, unit: .day),
                largestAllowedTotalSize: DataSize(value: 30, unit: .gibibyte)
            )
        ),
        style: .addNewDirectory,
        onDone: constant(.reject(reasonPresentedToUser: "This is a demo"))
    )
}
