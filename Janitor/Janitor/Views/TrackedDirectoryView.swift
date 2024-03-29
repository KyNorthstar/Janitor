//
//  TrackedDirectoryView.swift
//  TrackedDirectoryView
//
//  Created by Ky Leggiero on 2021-07-18.
//

import SwiftUI

import JanitorKit
import RectangleTools



private let hoverAnimation = Animation.easeInOut(duration: 0.25)



struct TrackedDirectoryView: View {
    
    @Binding
    private var trackedDirectory: TrackedDirectory
    
    @State
    private var isEditing = false
    
    private let onDeleteRequested: BlindCallback
    
    @State
    private var isHovering = false
    
    @Binding
    private var _viewRefreshHack: ViewRefreshHack
    
    
    init(_ trackedDirectory: Binding<TrackedDirectory>, onDeleteRequested: @escaping BlindCallback, _viewRefreshHack: Binding<ViewRefreshHack>) {
        self._trackedDirectory = trackedDirectory
        self.onDeleteRequested = onDeleteRequested
        self.__viewRefreshHack = _viewRefreshHack
    }
    
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if isHovering {
                Button(action: { isEditing = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .padding(EdgeInsets(eachVertical: 2, eachHorizontal: 4))
                }
                .buttonStyle(LinkButtonStyle())
                .transition(.opacity)
//                .border(Color.primary, width: 1)
            }
            
            DecorativePathView(trackedDirectory.url)
            
            MeasurementView(trackedDirectory.largestAllowedTotalSize)
                .fixedSize()
            
            MeasurementView(trackedDirectory.oldestAllowedAge)
                .fixedSize()
            
            Spacer()
            
            Toggle("Automatically clean this directory", isOn: $trackedDirectory.isEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .toggle))
                .labelsHidden()
        }
        
        .animation(hoverAnimation, value: isHovering)
        .frame(minHeight: 32)
        
        .editTrackedDirectory($trackedDirectory, isEditing: $isEditing, _viewRefreshHack: $_viewRefreshHack)
        
        .contextMenu {
            Button("Edit", action: { isEditing = true })
            Button("Delete", action: onDeleteRequested)
        }
        
        .onHover(perform: { isHovering = $0 })
    }
}



struct TrackedDirectoryView_Previews: PreviewProvider {
    static var previews: some View {
        TrackedDirectoryView(
            .constant(.init(
                uuid: UUID(),
                isEnabled: true,
                url: URL(fileURLWithPath: "/Path/To/File.txt"),
                oldestAllowedAge: .init(value: 7, unit: .day),
                largestAllowedTotalSize: .init(value: 2, unit: .gibibyte))),
            onDeleteRequested: null,
            _viewRefreshHack: .constant(.init())
        )
    }
}
