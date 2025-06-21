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



private struct TrackedDirectoryPicker: ViewModifier {
    
    @State
    private var workingTrackedDirectory: TrackedDirectory
    
    @Binding
    private var inoutTrackedDirectory: TrackedDirectory
    
    @State
    private var trackedDirectoryWasRejectedReason: Either<String, LocalizedStringKey>? = nil
    
    @State
    private var isSelectingNewDirectoryToTrack = false
    
    private let onDone: OnDone
    
    
    /// Creates a picker for a tracked directory.
    ///
    /// This will be presented as the system's default way of picking a directory, does some validation to ensure that the directory can be tracked.
    /// **and automatically bookmarks the directory the user selects.**
    ///
    /// If the user selects what this picker believes to be a valid directory to track, `trackedDirectory` is set to the directory the user tracked and `onDone` is passed `.confirm(proposal:)`.
    /// It's then your duty to evaluate the directory and decide whether it's good to use. If you decide that it is usable, return `.accept`.
    /// If you don't decide it's usable, return `.reject(reasonPresentedToUser:)` and this dialog will remain open and present your reason to the user.
    ///
    /// If the user selects what this picker believes to be an invalid directory to track (e.g. `/dev/null/`), 
    ///
    /// If the user cancels, then the `trackedDirectory` parameter is never changed and `onDone` is passed `.cancel`
    ///  In this case, what you return from `onDone` will be ignrored. I recommend you just return `.accept`.
    ///
    /// - Parameters:
    ///   - trackedDirectory:             The directory to pick. In the ideal path where the user selects a valid directory to trck, this is automatically set that directory.
    ///   - onDone:                       Called when the user dismisses this configuration view.
    ///                                   See the documentation for its parameter and return for specific behavior & expectations.
    init(for trackedDirectory: Binding<TrackedDirectory>,
         onDone: @escaping OnDone)
    {
        self._inoutTrackedDirectory = trackedDirectory
        self._workingTrackedDirectory = State(initialValue: trackedDirectory.wrappedValue)
        self.onDone = onDone
    }
    
    
    func body(content: Content) -> some View {
        content
        
        .fileImporter(isPresented: $isSelectingNewDirectoryToTrack,
                      allowedContentTypes: [.directory],
                      allowsMultipleSelection: false) { result in
            isSelectingNewDirectoryToTrack = true
            
            switch result {
            case .success(let directoryUrls):
                guard let directoryUrl = directoryUrls.first else {
                    log(error: "No selected URLs in the successfully-selected-URLs array?")
                    _ = onDone(.cancel) // I guess??
                    isSelectingNewDirectoryToTrack = false
                    trackedDirectoryWasRejectedReason = nil
                    return
                }
                
                workingTrackedDirectory.url = directoryUrl
                
                if directoryUrl.wouldBeDangerousToTrack {
                    workingTrackedDirectory.isEnabled = false
                }
                
                let shouldAccept = onDone(.confirm(proposal: workingTrackedDirectory))
                
                switch shouldAccept {
                case .accept:
                    isSelectingNewDirectoryToTrack = false
                    do {
                        try directoryUrl.saveToBookmarks()
                    }
                    catch {
                        log(error: error)
                        assertionFailure()
                    }
                    
                    inoutTrackedDirectory = workingTrackedDirectory
                    
                case .reject(reasonPresentedToUser: let rejectionReason):
                    isSelectingNewDirectoryToTrack = true
                    trackedDirectoryWasRejectedReason = rejectionReason
                }
                
            case .failure(let error):
                log(error: error)
                assertionFailure()
                trackedDirectoryWasRejectedReason = .left(error.bestDescription)
                isSelectingNewDirectoryToTrack = true
            }
        }
        onCancellation: {
            _ = onDone(.cancel)
        }
        
        
        .alert(
            "You might need to make some changes",
            presenting: $trackedDirectoryWasRejectedReason,
            message: { trackedDirectoryWasRejectedReason in
                Text(verbatimOrLocalized: trackedDirectoryWasRejectedReason)
            }
        )
    }
    
    
    
    typealias OnDone = OnUserDonePickingTrackedDirectory
}



/// The type of callback called when the user is done with this config view
public typealias OnUserDonePickingTrackedDirectory = (UserDonePickingTrackedDirectoryAction) -> ShouldAcceptUserDonePickingTrackedDirectoryAction



/// An action the user took when they were done this config
public enum UserDonePickingTrackedDirectoryAction {
    
    /// The user wants to close the config without changes.
    ///
    /// If this is passed, any returned acceptance will be ignored
    case cancel
    
    /// The user wants to commit the changes they made in this config
    /// - Parameter proposedChanges: The changes the user has made and wants to commit.
    ///                              **DO NOT USE THESE** to update anything;
    ///                              **ONLY VALIDATE** whether these changes are acceptable and return your decision using a ``ShouldAcceptUserDonePickingTrackedDirectoryAction`` value.
    case confirm(proposal: TrackedDirectory)
}



/// After the user has taken action to say they's done with this config, one of these must be returned back to them
public enum ShouldAcceptUserDonePickingTrackedDirectoryAction {
    
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



public extension View {
    
    @ViewBuilder
    func trackedDirectoryPicker(directory: Binding<TrackedDirectory?>, onDone: @escaping OnUserDonePickingTrackedDirectory) -> some View {
        if nil != directory.wrappedValue {
            modifier(TrackedDirectoryPicker(onDone: { action in
                switch action {
                case .cancel:
                    directory.wrappedValue = nil
                    return onDone(action)
                    
                case .confirm(proposal: _):
                    let response = onDone(action)
                    
                    switch response {
                    case .accept:
                        directory.wrappedValue = nil
                        
                    case .reject(reasonPresentedToUser: _):
                        break
                    }
                    
                    return response
                }
            }))
        }
        else {
            self
        }
    }
    
    
    @ViewBuilder
    func trackedDirectoryPicker(isPresented: Binding<Bool>, onDone: @escaping OnUserDonePickingTrackedDirectory) -> some View {
        if isPresented.wrappedValue {
            modifier(TrackedDirectoryPicker_JustBool(onDone: { action in
                switch action {
                case .cancel:
                    isPresented.wrappedValue = false
                    return onDone(action)
                    
                case .confirm(proposal: _):
                    let response = onDone(action)
                    
                    switch response {
                    case .accept:
                        isPresented.wrappedValue = false
                        
                    case .reject(reasonPresentedToUser: _):
                        break
                    }
                    
                    return response
                }
            }))
        }
        else {
            self
        }
    }
}



private struct TrackedDirectoryPicker_JustBool: ViewModifier {
    
    @State
    var tempTrackedDirectory: TrackedDirectory = .default()
    
    let onDone: OnUserDonePickingTrackedDirectory
    
    
    func body(content: Content) -> some View {
        content
            .modifier(TrackedDirectoryPicker(for: $tempTrackedDirectory, onDone: onDone))
    }
}



//#Preview("Downloads") {
//    TrackedDirectoryPicker(
//        for: .constant(
//            TrackedDirectory(
//                uuid: UUID(),
//                sort: nil,
//                isEnabled: true,
//                url: URL(fileURLWithPath: "\(NSHomeDirectory())/Downloads"),
//                oldestAllowedAge: Age(value: 30, unit: .day),
//                largestAllowedTotalSize: DataSize(value: 30, unit: .gibibyte)
//            )
//        ),
//        style: .addNewDirectory,
//        onDone: constant(.reject(reasonPresentedToUser: "This is a demo"))
//    )
//}
//
//#Preview("Root") {
//    TrackedDirectoryPicker(
//        for: .constant(
//            TrackedDirectory(
//                uuid: UUID(),
//                sort: nil,
//                isEnabled: true,
//                url: URL(fileURLWithPath: "/"),
//                oldestAllowedAge: Age(value: 30, unit: .day),
//                largestAllowedTotalSize: DataSize(value: 30, unit: .gibibyte)
//            )
//        ),
//        style: .addNewDirectory,
//        onDone: constant(.reject(reasonPresentedToUser: "This is a demo"))
//    )
//}
