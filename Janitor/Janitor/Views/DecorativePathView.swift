//
//  DecorativePathView.swift
//  Janitor
//
//  Created by Ky Leggiero on 2021-07-24.
//

import SwiftUI

import Introspection


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
                    .replacingUserHome(with: "🏡")
                    .withFancyPathSeparators(keepTrailingSeparator: true, ifEmpty: .emojiRepresentingThisDevice + fancyPathSeparator)
            )
                .truncationMode(.middle)
                .lineLimit(1)
                .foregroundColor(.secondary)
                
            
            Text(url.lastPathComponent)
                .font(.title.bold())
        }
        .help(url.path)
        .accessibility(label: Text(url.replacingUserHome(with: "Your home folder ")))
    }
}

struct DecorativeUrlView_Previews: PreviewProvider {
    static var previews: some View {
        DecorativePathView(URL(fileURLWithPath: "/Path/To/File.txt"))
        DecorativePathView(URL(fileURLWithPath: "\(NSHomeDirectory())/Desktop"))
    }
}



private extension URL {
    func replacingUserHome(with replacement: String) -> String {
        path.replacingOccurrences(of: "/Users/\(NSUserName())", with: replacement, options: .anchored, range: nil)
    }
}



private extension String {
    func withFancyPathSeparators(keepTrailingSeparator: Bool, ifEmpty: @autoclosure () -> String = "") -> String {
        
        var path = self
        
        if first == "/" {
            path = .init(path.dropFirst())
        }
        
        if path.isEmpty {
            return ifEmpty()
        }
        
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
