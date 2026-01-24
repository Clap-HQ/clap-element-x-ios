//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct ClapDeveloperModeScreen: View {
    @Bindable var context: ClapDeveloperModeScreenViewModel.Context

    @AppStorage(ClapDeveloperModeSettings.StorageKeys.spaceSettingsEnabled, store: ClapDeveloperModeSettings.store)
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
                Toggle(isOn: $context.showAdvancedOptions) {
                    Text("Show Advanced Options")
                    Text("Show View Source, Hide Invite Avatars, Timeline Media, Labs, and Report a Problem options")
                        .font(.compound.bodySM)
                        .foregroundColor(.compound.textSecondary)
                }
            } header: {
                Text("Settings")
            }
        }
        .compoundList()
        .navigationTitle("Clap Developer Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

struct ClapDeveloperModeScreen_Previews: PreviewProvider {
    static let viewModel = ClapDeveloperModeScreenViewModel(clapDeveloperModeSettings: ClapDeveloperModeSettings())

    static var previews: some View {
        NavigationStack {
            ClapDeveloperModeScreen(context: viewModel.context)
        }
    }
}
