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
final class ClapDeveloperModeSettings {
    private enum Keys: String {
        case showCustomHomeserver
        case showQRCodeLogin
        case groupSpaceRooms
        case showAdvancedOptions
    }

    private static var suiteName: String = InfoPlistReader.main.appGroupIdentifier
    private static var store: UserDefaults! = UserDefaults(suiteName: suiteName)

    /// Whether to show the custom homeserver option in the authentication flow.
    @UserPreference(key: Keys.showCustomHomeserver, defaultValue: false, storageType: .userDefaults(store))
    var showCustomHomeserver

    /// Whether to show the QR code login button in the authentication flow.
    @UserPreference(key: Keys.showQRCodeLogin, defaultValue: false, storageType: .userDefaults(store))
    var showQRCodeLogin

    /// Whether to group space-affiliated rooms under space cells in chat tab.
    /// When enabled, rooms belonging to spaces are hidden from the main chat list and shown in space room list instead.
    @UserPreference(key: Keys.groupSpaceRooms, defaultValue: true, storageType: .userDefaults(store))
    var groupSpaceRooms

    /// Whether to show advanced options (View Source, Hide Invite Avatars, Timeline Media, Labs, Report a Problem).
    @UserPreference(key: Keys.showAdvancedOptions, defaultValue: false, storageType: .userDefaults(store))
    var showAdvancedOptions
}
