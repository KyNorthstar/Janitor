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
    
    
    init(trackedDirectory: Binding<TrackedDirectory>, isEditing: Binding<Bool>, _viewRefreshHack: Binding<ViewRefreshHack>) {
        self._trackedDirectory = trackedDirectory
        self._isEditing = isEditing
        self.__viewRefreshHack = _viewRefreshHack
    }
    
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isEditing, onDismiss: { self._viewRefreshHack.refresh() }) {
                TrackedDirectoryConfigurationView(for: $trackedDirectory, onDone: { isEditing = false })
            }
    }
}



extension View {
    
    /// When `isEditing` is `true`, this presents a sheet to edit that directory. Edits are applied directly to the tracked directory binding you pass here.
    ///
    /// - Parameters:
    ///   - trackedDirectory: The directory to edit
    ///   - isEditing:        Whether the directory is currently being edited
    func editTrackedDirectory(
        _ trackedDirectory: Binding<TrackedDirectory>,
        isEditing: Binding<Bool>,
        _viewRefreshHack: Binding<ViewRefreshHack>)
    -> some View {
        self.modifier(EditTrackedDirectorySheet(
            trackedDirectory: trackedDirectory,
            isEditing: isEditing,
            _viewRefreshHack: _viewRefreshHack))
    }
}
