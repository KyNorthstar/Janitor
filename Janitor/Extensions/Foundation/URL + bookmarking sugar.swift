//
//  URL + bookmarking sugar.swift
//  Janitor
//
//  Created by Ky on 2024-10-04.
//

import Foundation

import JanitorKit

import OptionalTools
import SimpleLogging



private let bookmarksSavingDirectory = URL.myApplicationSupport / "File Permissions"



public extension URL {
    
    /// Save the current permissions for this URL access to the app's permisison "bookmarks"
    func saveToBookmarks() throws {
        // https://developer.apple.com/documentation/professional-video-applications/creating-bookmark-data

        // Start accessing security scoped resource
        guard self.startAccessingSecurityScopedResource() else {
            log(error: "Attempted to save to bookmarks a URL which couldn't be accessed: \(self)")
            assertionFailure()
            return
        }
        defer { self.stopAccessingSecurityScopedResource() }
        
        let bookmarkSavingUrl = bookmarkSavingUrl
        
        // Create bookmark
        let bookmark = try self.bookmarkData(options: .withSecurityScope)
        try FileManager.default.createDirectory(at: bookmarkSavingUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: bookmarkSavingUrl.actualPath, contents: nil)
        try bookmark.write(to: bookmarkSavingUrl)
    }
    
    
    /// The URL where URL permission "bookmarks" are stored for this app
    var bookmarkSavingUrl: URL {
        bookmarksSavingDirectory / "\(lastPathComponent).bookmark"
    }
    
    
    private func __loadingFromBookmarks() throws(BookmarkLoadError) -> Self {
        // https://developer.apple.com/documentation/professional-video-applications/using-bookmark-data
        
        let bookmark = try mapError { try self.bookmarkData(options: .withSecurityScope) }
            errorMapper: { bookmarkDataError in
                BookmarkLoadError.couldNotReadBookmarkData(readError: bookmarkDataError)
            }
        
        // Decode the Base64 bookmark data
        let decodedBookmark = try Data(base64Encoded: bookmark, options: .ignoreUnknownCharacters)
            .unwrappedOrThrow(error: BookmarkLoadError.failedToDecodeBase64BookmarkData)


        // Resolve the decoded bookmark data into a security-scoped URL.
        var bookmarkDataIsStale = Bool()
        return try mapError {
            try URL(resolvingBookmarkData: decodedBookmark,
                    options: .withSecurityScope,
                    bookmarkDataIsStale: &bookmarkDataIsStale)
        }
        errorMapper: { bookmarkResolutionError in
            BookmarkLoadError.failedToResolveBookmarkData(resolutionError: bookmarkResolutionError)
        }
    }
    
    
    /// Replace this URL with its version that was loaded from the URL permission "bookmarks"
    ///
    /// - Throws: Any error thrown when trying to access the bookmark data andor the URL resolved from it
    mutating func loadFromBookmarks() throws {
        self = try __loadingFromBookmarks()
    }
    
    
    /// Load the URL permission "bookmarks" version of this URL, and pass it to the given callback
    ///
    /// - Parameters:
    ///   - automaticallyStartAccessing: _optional_ - Whether to automatically start accessing the security-scoped resource before calling `onDidLoad`.
    ///                                  If this is set to `true`, then this function also takes responsibility to stop accessing the resource after the callback completes, regardless of whether it throws an error.
    ///                                  If this is set to `false` then this function simply passes the resolved "bookmark" to `onDidLoad` and does nothing else.
    ///                                  Defaults to `true`
    ///   - onDidLoad:                   Iff the "bookmark" version of this URL was successfully loaded, then it's passed to this callback.
    ///                                  Otherwise, an error is thrown and this callback isn't called.
    ///                                  This callback can optionally choose to return a value, which is then blindly returned by this function.
    ///
    /// - Returns: Whatever `onDidLoad` returns.
    func loadingFromBookmarks<Return>(automaticallyStartAccessing: Bool = true, _ onDidLoad: (URL) throws -> Return) throws -> Return {
        let loaded = try __loadingFromBookmarks()
        
        if automaticallyStartAccessing {
            return try accessSecurityScopedResource {
                try onDidLoad(loaded)
            }
        }
        else {
            return try onDidLoad(loaded)
        }
    }
    
    
    
    /// Any error which might occur while attempting to load the URL permissions "bookmark" version of a URL
    enum BookmarkLoadError: LocalizedError {
        
        case couldNotReadBookmarkData(readError: Error)
        
        case failedToDecodeBase64BookmarkData
        
        case failedToResolveBookmarkData(resolutionError: Error)
        
        public var errorDescription: String? {
            switch self {
            case .couldNotReadBookmarkData(readError: let readError):
                String(localized: "BookmarkLoadError.couldNotReadBookmarkData(readError: \(readError.bestDescription))",
                       comment: "we could not find the bookmark data, or attempting to read it at all resulted in an error")
                
            case .failedToDecodeBase64BookmarkData:
                String(localized: "BookmarkLoadError.failedToDecodeBase64BookmarkData",
                       comment: "when we found the bookmark data as a Base64-encoded string and tried to decode it, but the decoding failed")
                
            case .failedToResolveBookmarkData(resolutionError: let resolutionError):
                String(localized: "BookmarkLoadError.failedToResolveBookmarkData(resolutionError: \(resolutionError.bestDescription))",
                       comment: "we found & decoded the bookmark data, but could not resolve it")
            }
        }
    }
}
