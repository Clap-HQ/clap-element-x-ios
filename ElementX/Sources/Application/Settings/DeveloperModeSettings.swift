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
    }

    private static var suiteName: String = InfoPlistReader.main.appGroupIdentifier
    private static var store: UserDefaults! = UserDefaults(suiteName: suiteName)

    /// Whether to show the custom homeserver option in the authentication flow.
    @UserPreference(key: Keys.showCustomHomeserver, defaultValue: false, storageType: .userDefaults(store))
    var showCustomHomeserver
}
