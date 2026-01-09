//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct DeveloperModeScreen: View {
    @Bindable var context: DeveloperModeScreenViewModel.Context

    @AppStorage("spaceSettingsEnabled", store: UserDefaults(suiteName: InfoPlistReader.main.appGroupIdentifier))
    private var spaceSettingsEnabled = true

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $context.showCustomHomeserver) {
                    Text("Show Custom Homeserver")
                    Text("Show the change account provider button in sign-in flow")
                        .font(.compound.bodySM)
                        .foregroundColor(.compound.textSecondary)
                }
                Toggle(isOn: $context.showQRCodeLogin) {
                    Text("Show QR Code Login")
                    Text("Show the sign in with QR code button")
                        .font(.compound.bodySM)
                        .foregroundColor(.compound.textSecondary)
                }
            } header: {
                Text("Authentication")
            }

            Section {
                Toggle(isOn: $context.groupSpaceRooms) {
                    Text("Group Space Rooms")
                    Text("Hide space-affiliated rooms from chat tab and show them under space cells instead")
                        .font(.compound.bodySM)
                        .foregroundColor(.compound.textSecondary)
                }
                Toggle(isOn: $spaceSettingsEnabled) {
                    Text("Space Settings")
                    Text("Enable space settings and permissions management features")
                        .font(.compound.bodySM)
                        .foregroundColor(.compound.textSecondary)
                }
            } header: {
                Text("Spaces")
            }

            Section {
                Toggle(isOn: $context.showDeveloperSettings) {
                    Text("Show Developer Settings")
                    Text("Show View Source, Hide Invite Avatars, Timeline Media, Labs, and Report a Problem options")
                        .font(.compound.bodySM)
                        .foregroundColor(.compound.textSecondary)
                }
            } header: {
                Text("Settings")
            }
        }
        .compoundList()
        .navigationTitle("Developer Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

struct DeveloperModeScreen_Previews: PreviewProvider {
    static let viewModel = DeveloperModeScreenViewModel(developerModeSettings: ServiceLocator.shared.developerModeSettings)

    static var previews: some View {
        NavigationStack {
            DeveloperModeScreen(context: viewModel.context)
        }
    }
}
