//
//  DecorativePathView.swift
//  Janitor
//
//  Created by Ky Leggiero on 2021-07-24.
//

import SwiftUI
import RegexBuilder

import Introspection
import JanitorKit


private let fancyPathSeparator = " ❯ "



struct DecorativePathView: View {
    
    private let url: URL
    
    
    public init(_ url: URL) {
        self.url = url
    }
    
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Text(
                url.deletingLastPathComponent()
                    .standardizedFileURL
                    .path(replacingUserHomeWith: "🏡")
                    .withFancyPathSeparators(keepTrailingSeparator: true, ifEmpty: .emojiRepresentingThisDevice + fancyPathSeparator)
            )
                .truncationMode(.middle)
                .lineLimit(1)
                .foregroundColor(.secondary)
                .layoutPriority(1)
            
            if url.isRoot {
                Text(Introspection.Device.current.userAssignedName.map { "All of \($0)" }
                     ?? "(whole \(Introspection.Device.current.genericName ?? "Mac")")
                    .font(.largeTitle.weight(.black))
            }
            else {
                Text(url.lastPathComponent)
                    .font(.title.bold())
                    .lineLimit(1)
                    .layoutPriority(2)
            }
        }
        .help(url.path)
        .accessibility(label: Text(url.path(replacingUserHomeWith: "Your home folder ")))
        
        .frame(height: NSFontDescriptor.preferredFontDescriptor(forTextStyle: .title1).pointSize)
    }
}



#Preview("small") {
    DecorativePathView(URL(fileURLWithPath: "\(NSHomeDirectory())/Pictures/Screenshots"))
        .frame(width: 100)
}

#Preview("User desktop") {
    DecorativePathView(URL(fileURLWithPath: "\(NSHomeDirectory())/Desktop"))
}

#Preview("Root") {
    DecorativePathView(URL(fileURLWithPath: "/"))
}



private extension URL {
    func path(replacingUserHomeWith replacement: String) -> String {
        path.replacing(
            Regex {
                // /^\(NSHomeDirectory())/
                Anchor.startOfSubject
                NSHomeDirectory()
            },
            with: replacement)
    }
}



private extension String {
    func withFancyPathSeparators(keepTrailingSeparator: Bool, ifEmpty: @autoclosure () -> String = "") -> String {
//        return "\"\(self)\""
        
        var path = self
        
        if first == "/" {
            path = .init(path.dropFirst())
        }
        
        guard path.isNotEmpty else {
            return ifEmpty()
        }
//        return "\"\(path)\""
        
        if keepTrailingSeparator {
            path += "/"
        }
        
        return path.replacingOccurrences(of: "/", with: fancyPathSeparator)
    }
    
    
    static var emojiRepresentingThisDevice: String {
        switch Introspection.Device.deviceClass {
        case .desktop: return "🖥"
        case .laptop: return "💻"
        case .tablet, .phone, .portableMusicPlayer: return "📱"
        case .watch: return "⌚️"
        case .tvBox: return "📺"
        case .none: return "🗂"
        }
    }
}
