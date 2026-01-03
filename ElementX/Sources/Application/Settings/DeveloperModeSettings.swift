//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation

/// Settings for Developer Mode feature flags.
/// These flags control experimental features that are hidden from regular users.
final class DeveloperModeSettings {
    private enum Keys: String {
        case showCustomHomeserver
        case showQRCodeLogin
        case groupSpaceChannels
    }

    private static var suiteName: String = InfoPlistReader.main.appGroupIdentifier
    private static var store: UserDefaults! = UserDefaults(suiteName: suiteName)

    /// Whether this is the Clap Dev scheme (Debug build)
    private static var isClapDev: Bool {
        InfoPlistReader.main.baseBundleIdentifier == "ac.clap.app.dev"
    }

    /// Whether to show the custom homeserver option in the authentication flow.
    @UserPreference(key: Keys.showCustomHomeserver, defaultValue: isClapDev, storageType: .userDefaults(store))
    var showCustomHomeserver

    /// Whether to show the QR code login button in the authentication flow.
    @UserPreference(key: Keys.showQRCodeLogin, defaultValue: isClapDev, storageType: .userDefaults(store))
    var showQRCodeLogin

    /// Whether to group space-affiliated channels under space cells in chat tab.
    /// When enabled, channels belonging to spaces are hidden from the main chat list and shown in space channel list instead.
    @UserPreference(key: Keys.groupSpaceChannels, defaultValue: true, storageType: .userDefaults(store))
    var groupSpaceChannels
}
