//
//  EditTrackedDirectorySheet.swift
//  EditTrackedDirectorySheet
//
//  Created by Ky Leggiero on 2021-07-25.
//

import SwiftUI

import JanitorKit



struct EditTrackedDirectorySheet: ViewModifier {
    
    @Binding
    private var trackedDirectory: TrackedDirectory
    
    @Binding
    private var isEditing: Bool
    
    @Binding
    private var _viewRefreshHack: ViewRefreshHack
    
    private let onDone: OnDone
    
    
    /// When `isEditing` is `true`, this presents a sheet to edit that directory. Edits are applied directly to the tracked directory binding you pass here.
    ///
    /// - Parameters:
    ///   - trackedDirectory:             The directory to edit
    ///   - isEditing:                    Whether the directory is currently being edited
    ///   - onDone:                       Called when the user dismisses this configuration view.
    ///                                   See the documentation for its parameter and return for specific behavior & expectations.
    init(trackedDirectory: Binding<TrackedDirectory>, isEditing: Binding<Bool>, _viewRefreshHack: Binding<ViewRefreshHack>, onDone: @escaping OnDone) {
        self._trackedDirectory = trackedDirectory
        self._isEditing = isEditing
        self.__viewRefreshHack = _viewRefreshHack
        self.onDone = onDone
    }
    
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isEditing, onDismiss: { _viewRefreshHack.refresh() }) {
                TrackedDirectoryConfigurationView(for: $trackedDirectory, style: .updateExistingDirectory) { userAction in
                    let shouldAccept = onDone(userAction)
                    
                    switch shouldAccept {
                    case .accept:
                        isEditing = false
                        
                    case .reject(reasonPresentedToUser: _):
                        break
                    }
                    
                    return shouldAccept
                }
            }
    }
    
    
    
    typealias OnDone = TrackedDirectoryConfigurationView.OnDone
}



extension View {
    
    /// When `isEditing` is `true`, this presents a sheet to edit that directory. Edits are applied directly to the tracked directory binding you pass here.
    ///
    /// - Parameters:
    ///   - trackedDirectory:             The directory to edit
    ///   - isEditing:                    Whether the directory is currently being edited
    func editTrackedDirectory(
        _ trackedDirectory: Binding<TrackedDirectory>,
        isEditing: Binding<Bool>,
        _viewRefreshHack: Binding<ViewRefreshHack>,
        onDone: @escaping EditTrackedDirectorySheet.OnDone)
    -> some View {
        self.modifier(EditTrackedDirectorySheet(
            trackedDirectory: trackedDirectory,
            isEditing: isEditing,
            _viewRefreshHack: _viewRefreshHack,
            onDone: onDone))
    }
}
