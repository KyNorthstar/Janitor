//
//  TrackedDirectoryView.swift
//  TrackedDirectoryView
//
//  Created by Ky Leggiero on 2021-07-18.
//

import SwiftUI

import Introspection
import JanitorKit
import RectangleTools



private let hoverAnimation = Animation.easeInOut(duration: 0.25)



struct TrackedDirectoryView: View {
    
    @Binding
    private var trackedDirectory: TrackedDirectory
    
    @State
    private var isEditing = false
    
    @State
    private var showFolderPicker = false
    
    private let onDeleteRequested: BlindCallback
    
    @State
    private var isHovering = false
    
    @Binding
    private var _viewRefreshHack: ViewRefreshHack
    
    private let onUserDoneEditing: OnUserDoneEditing
    
    
    init(_ trackedDirectory: Binding<TrackedDirectory>,
         onDeleteRequested: @escaping BlindCallback,
         _viewRefreshHack: Binding<ViewRefreshHack>,
         onUserDoneEditing: @escaping OnUserDoneEditing)
    {
        self._trackedDirectory = trackedDirectory
        self.onDeleteRequested = onDeleteRequested
        self.__viewRefreshHack = _viewRefreshHack
        self.onUserDoneEditing = onUserDoneEditing
    }
    
    
    var body: some View {
        listingView
            .animation(.bouncy, value: isHovering.hashValue)
        
            .frame(minHeight: 32)
        
            .editTrackedDirectory(
                $trackedDirectory,
                isEditing: $isEditing,
                _viewRefreshHack: $_viewRefreshHack,
                onDone: onUserDoneEditing)
        
        
            .onHover(perform: { isHovering = $0 })
        
            .contextMenu {
                Button("Edit", action: { isEditing = true })
                Button("Delete", action: onDeleteRequested)
            }
    }
    
    
    private var editButton: some View {
        Button(action: { isEditing = true }) {
            Image(systemName: "pencil")
                .padding(EdgeInsets(eachVertical: 2, eachHorizontal: 4))
        }
//        .buttonStyle(LinkButtonStyle())
        .buttonStyle(.bordered)
//        .fixedSize()
        .foregroundStyle(Color.accentColor)
    }
    
    
    private var listingView: some View {
        HStack(alignment: .firstTextBaseline) {
            switch Introspection.Permission.fileAccess(trackedDirectory.url) {
            case .noAccess,
                    .read,
                    .readWrite(canDelete: false):
                noAccessButton
                
            case .readWrite(canDelete: true):
                EmptyView()
            }
            
            Group {
                DecorativePathView(trackedDirectory.url)
                    .foregroundColor(trackedDirectory.url.wouldBeDangerousToTrack ? .red : nil)
                //                .transition(.opacity.animation(.bouncy))
                
                MeasurementView(trackedDirectory.largestAllowedTotalSize)
                    .fixedSize()
                
                MeasurementView(trackedDirectory.oldestAllowedAge)
                    .fixedSize()
            }
            .opacity(.readWrite(canDelete: true) == Introspection.Permission.fileAccess(trackedDirectory.url)
                     ? 1
                     : 0.5)
            
            
            Spacer()
            
            editButton
                .opacity(isHovering ? 1 : 0)
                .animation(.bouncy, value: isHovering)
            
            Toggle("Automatically clean this directory", isOn: $trackedDirectory.isEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .toggle))
                .labelsHidden()
                .help("Turn this janitor \(trackedDirectory.isEnabled ? "off" : "on")")
        }
    }
    
    
    private var noAccessButton: some View {
        Button {
            showFolderPicker = true
        } label: {
            Label {
                Text("No Access")
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.black, .orange, .orange)
                    .symbolEffect(.pulse)
                    .fontWeight(.black)
            }
        }
        .buttonStyle(.accessoryBarAction)
        .padding(.horizontal)
        .foregroundStyle(.orange)
        .fontWeight(.black)
        .fixedSize()
        
        .trackedDirectoryPicker(isPresented: $showFolderPicker) { result in
            <#code#>
        }
    }
    
    
    
    typealias OnUserDoneEditing = EditTrackedDirectorySheet.OnDone
}



#Preview("Typical") {
    TrackedDirectoryView(
        .constant(.init(
            uuid: UUID(),
            sort: nil,
            isEnabled: true,
            url: URL(fileURLWithPath: "~/Pictures/Screenshots").expandingTildeInPath,
            oldestAllowedAge: .init(value: 7, unit: .day),
            largestAllowedTotalSize: .init(value: 2, unit: .gibibyte))),
        onDeleteRequested: null,
        _viewRefreshHack: .constant(.init()),
        onUserDoneEditing: constant(.accept)
    )
}



#Preview("Thin") {
    TrackedDirectoryView(
        .constant(.init(
            uuid: UUID(),
            sort: nil,
            isEnabled: true,
            url: URL(fileURLWithPath: "~/Pictures/Screenshots").expandingTildeInPath,
            oldestAllowedAge: .init(value: 7, unit: .day),
            largestAllowedTotalSize: .init(value: 2, unit: .gibibyte))),
        onDeleteRequested: null,
        _viewRefreshHack: .constant(.init()),
        onUserDoneEditing: constant(.accept)
    )
    .frame(width: 300)
}



#Preview("Inaccessible") {
    TrackedDirectoryView(
        .constant(.init(
            uuid: UUID(),
            sort: nil,
            isEnabled: true,
            url: URL(fileURLWithPath: "/var").expandingTildeInPath,
            oldestAllowedAge: .init(value: 7, unit: .day),
            largestAllowedTotalSize: .init(value: 2, unit: .gibibyte))),
        onDeleteRequested: null,
        _viewRefreshHack: .constant(.init()),
        onUserDoneEditing: constant(.accept)
    )
}
