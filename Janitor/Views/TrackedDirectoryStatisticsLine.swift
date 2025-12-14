//
//  TrackedDirectoryStatisticsLine.swift
//  Janitor
//
//  Created by Ky on 2025-10-26.
//

import SwiftUI

import JanitorKit
import SimpleLogging



struct TrackedDirectoryStatisticsLine: View {
    
    let trackedDirectory: TrackedDirectory
    
    @State
    private var stats: Loading<TrackedDirectory.Stats, Never> = .loading
    
    
    var body: some View {
        HStack(alignment: .center) {
            switch stats.fileCount {
            case .loading:
                Text("... files")
                
            case .success(.none):
                Text("Couldn't get file count")
                
            case .success(.some(let currentFileCount)):
                Text("\(currentFileCount) files")
                    .fixedSize()
                
            case .failure(let failure):
                Text("Error getting file count")
                    .task {
                        log(error: failure)
                    }
            }
            
            let currentTotalSize = stats.totalSize
            let quota = trackedDirectory.largestAllowedTotalSize
            let ageQuota = trackedDirectory.oldestAllowedAge
            
            
            VStack(alignment: .trailing, spacing: 0) {
                switch currentTotalSize {
                case .loading:
                    Text("...")
                    
                case .success(let currentTotalSize):
                    Text("\(currentTotalSize?.absoluteValue.bestDescription ?? "???") / \(quota.bestDescription)")
                    
                case .failure(let failure):
                    Text("Error getting file size")
                        .task {
                            log(error: failure)
                        }
                }
                
                let ageDescription = switch stats.oldestFile {
                case .loading:
                    "..."
                    
                case .success(.none):
                    "???"
                    
                case .success(.some(let oldestFile)):
                    oldestFile.age.converted(to: .day).value.formatted(.number.rounded().precision(.fractionLength(0)))
                    
                case .failure(_):
                    "???"
                }
                
                Text("\(ageDescription) / \(ageQuota.converted(to: .day).value.formatted(.number.rounded().precision(.fractionLength(0...2)))) days old")
            }
            .controlSize(.mini)
            .fixedSize()
            .font(.footnote.monospacedDigit())
            
            switch currentTotalSize {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.mini)
                
            case .success(.none):
                Text("?")
                
            case .success(.some(let currentTotalSize)):
                ProgressView(value: currentTotalSize.quotaPercentage, total: 1)
                    .progressViewStyle(.circular)
                    .controlSize(.mini)
                
            case .failure(let failure):
                Text("Error getting total size")
                    .task {
                        log(error: failure)
                    }
            }
        }
        .foregroundColor(.secondary)
        .task {
                self.stats = .success(await trackedDirectory.currentStats)
        }
    }
}



@dynamicMemberLookup
enum Loading<Success, Failure: Error> {
    case loading
    case success(Success)
    case failure(Failure)
    
    
    subscript <Subject>(dynamicMember keyPath: KeyPath<Success, Subject>) -> Loading<Subject, Failure> {
        switch self {
        case .loading:
            return .loading
            
        case .success(let value):
            return .success(value[keyPath: keyPath])
            
        case .failure(let failure):
            return .failure(failure)
        }
    }
}



private struct CoundNotGetStats: Error {}



#Preview {
    TrackedDirectoryStatisticsLine(trackedDirectory:
            .init(
                uuid: UUID(),
                sort: nil,
                isEnabled: true,
                url: URL(fileURLWithPath: "~/Downloads").expandingTildeInPath,
                oldestAllowedAge: .init(value: 7, unit: .day),
                largestAllowedTotalSize: .init(value: 2, unit: .gibibyte))
    )
    .border(Color.green)
    .padding()
}
