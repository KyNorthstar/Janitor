//
//  AutoDeleteDangerConsentPanel.swift
//  Janitor
//
//  Created by Ky on 2024-09-26.
//

import SwiftUI

import JanitorKit

import Introspection



public struct AutoDeleteDangerConsentPanel: View {
    
    private let danger: AutoDeleteDanger
    
    private let workingTrackedDirectory: TrackedDirectory
    
    @Binding
    private var userDefinitelyDidConsent: Bool
    
    
    public init?(workingTrackedDirectory: TrackedDirectory,
                 userDefinitelyDidConsent: Binding<Bool>)
    {
        guard let danger = workingTrackedDirectory.url.autoDeleteDanger else {
            return nil
        }
        
        self.danger = danger
        self.workingTrackedDirectory = workingTrackedDirectory
        self._userDefinitelyDidConsent = userDefinitelyDidConsent
    }
    
    
    public var body: some View {
        switch danger {
        case .root:
            TrackWholeMachine(workingTrackedDirectory: workingTrackedDirectory, userDefinitelyDidConsent: $userDefinitelyDidConsent)
            
        case .system:
            Text("TODO: System Consent")
            
        case .userHome(let userHome):
            Text("TODO: User domain consent for \(userHome)")
        }
    }
}



private extension AutoDeleteDangerConsentPanel {
    struct TrackWholeMachine: View {
        
        @State
        private var userConsentToTrackRoot = UserConsentToTrackRoot()
        
        
        let workingTrackedDirectory: TrackedDirectory
        
        @Binding
        var userDefinitelyDidConsent: Bool
        
        
        public var body: some View {
            VStack(alignment: .leading) {
                Label {
                    Text("CAREFUL!")
                        .font(.largeTitle.weight(.black))
                        .foregroundStyle(.red)
                } icon: {
                    Image(systemName: "externaldrive.fill.trianglebadge.exclamationmark")
                        .foregroundStyle(.red)
                        .symbolRenderingMode(.multicolor)
                        .symbolEffect(.pulse)
                        .font(.largeTitle)
                }
                
                let deviceName: String = Introspection.Device.current.userAssignedName
                ?? String(localized: "this \(Introspection.Device.current.genericName ?? "Mac")")
                
                Text.init("""
                    You've selected the entire Mac to be cleaned automatically by \(Introspection.appName).
                    **You must select a different folder** or heed the following warning:
                    
                    This means that you are asking \(Introspection.appName) to delete **any and all files on \(deviceName)** which are older than \(workingTrackedDirectory.oldestAllowedAge.bestDescription), or **delete all old files** if you have used more than \(workingTrackedDirectory.largestAllowedTotalSize.bestDescription) of the drive space.
                    
                    If you continue, **you might never be able to use \(deviceName) ever again.**
                    """)
                //                    .textSelection(.enabled)
                //                    .multilineTextAlignment(.leading)
                
                //                    .lineLimit(nil)
                //                    .truncationMode(.head)
                //                    .frame(minHeight: 9, maxHeight: .infinity)
                //                    .fixedSize(horizontal: false, vertical: true)
                //                    .layoutPriority(.infinity)
                
                Form {
                    Section {
                        ForEach(userConsentToTrackRoot.checkboxesOrder, id: \.self) { index in
                            switch index {
                            case 1:
                                Toggle(isOn: $userConsentToTrackRoot.didReadWarning.didCheck) {
                                    Text(     userConsentToTrackRoot.didReadWarning.text)
                                }
                                
                            case 2:
                                Toggle(isOn: $userConsentToTrackRoot.understandsTheyCanChangeTheSelectedDir.didCheck) {
                                    Text(     userConsentToTrackRoot.understandsTheyCanChangeTheSelectedDir.text)
                                }
                                
                            case 3:
                                Toggle(isOn: $userConsentToTrackRoot.understandsThatSelectingRootCanDestroyThisMachine.didCheck) {
                                    Text(     userConsentToTrackRoot.understandsThatSelectingRootCanDestroyThisMachine.text(deviceName))
                                }
                                
                            case 4:
                                Toggle(isOn: $userConsentToTrackRoot.attentionCheck_MUST_REMAIN_UNCHECKED.didCheck) {
                                    Text(     userConsentToTrackRoot.attentionCheck_MUST_REMAIN_UNCHECKED.text)
                                }
                                
                            default:
                                Text("🐞 This text isn't supposed to appear! 👻 Ooooo it's an ooky spooky bug! 😲 Report it!")
                            }
                        }
                    }
                    
                    Section {
                        TextField(
                            "Type this exactly",
                            text: $userConsentToTrackRoot.finalManuallyTypedConsent.userCopy,
                            prompt: Text("\"\(Text(userConsentToTrackRoot.finalManuallyTypedConsent.copy))\""))
                        .labelsHidden()
                    } footer: {
                        Text("Type \"\(Text(userConsentToTrackRoot.finalManuallyTypedConsent.copy))\" in this text field")
                    }
                }
                .toggleStyle(.checkbox)
                .foregroundStyle(.secondary)
                .padding()
            }
            //                .fixedSize(horizontal: false, vertical: true)
            
            .animation(.bouncy(duration: 0.5), value: workingTrackedDirectory)
            .transition(.move(edge: .top).animation(.bouncy(duration: 0.5)))
            
            .onChange(of: userConsentToTrackRoot) { _, newValue in
                userDefinitelyDidConsent = newValue.userDefinitelyDidConsent
            }
        }
        
        
        
        struct UserConsentToTrackRoot: Equatable {
            
            let checkboxesOrder = (1...4).shuffled()
            
            var didReadWarning =
                (didCheck: false, text: "I have read the warning above." as LocalizedStringKey)
            
            var understandsTheyCanChangeTheSelectedDir =
                (didCheck: false, text: "I understand that selecting another folder would be safer." as LocalizedStringKey)
            
            var understandsThatSelectingRootCanDestroyThisMachine =
                (didCheck: false, text: { (_ deviceName: String) in
                    "I understand that this selection can delete extremely important files, and might cause damage to \(deviceName) which cannot be undone." as LocalizedStringKey
                })
            
            var attentionCheck_MUST_REMAIN_UNCHECKED =
                (didCheck: false, text: "I understand that this check box must remain unchecked for me to proceed." as LocalizedStringKey)
            
            
            var finalManuallyTypedConsent =
                (userCopy: "", copy: String(localized: "Allow \(Introspection.appName) to delete anything at all"))
            
            
            var userDefinitelyDidConsent: Bool {
                didReadWarning.didCheck
                    && understandsTheyCanChangeTheSelectedDir.didCheck
                    && understandsThatSelectingRootCanDestroyThisMachine.didCheck
                    && !attentionCheck_MUST_REMAIN_UNCHECKED.didCheck
                    && (finalManuallyTypedConsent.userCopy == finalManuallyTypedConsent.copy)
            }
            
            
            
            static func == (lhs: Self, rhs: Self) -> Bool {
                   lhs.checkboxesOrder                                            == rhs.checkboxesOrder
                && lhs.didReadWarning.didCheck                                    == rhs.didReadWarning.didCheck
                && lhs.understandsTheyCanChangeTheSelectedDir.didCheck            == rhs.understandsTheyCanChangeTheSelectedDir.didCheck
                && lhs.understandsThatSelectingRootCanDestroyThisMachine.didCheck == rhs.understandsThatSelectingRootCanDestroyThisMachine.didCheck
                && lhs.attentionCheck_MUST_REMAIN_UNCHECKED.didCheck              == rhs.attentionCheck_MUST_REMAIN_UNCHECKED.didCheck
                && lhs.finalManuallyTypedConsent.userCopy                         == rhs.finalManuallyTypedConsent.userCopy
            }
        }
    }
}



#Preview {
    AutoDeleteDangerConsentPanel(
        workingTrackedDirectory: TrackedDirectory(
            uuid: .init(),
            sort: nil,
            url: .rootDirectory,
            oldestAllowedAge: Age(value: 30, unit: .day),
            largestAllowedTotalSize: DataSize(value: 30, unit: .gibibyte)
        ),
        userDefinitelyDidConsent: .constant(false)
    )
}
