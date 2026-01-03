//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation

enum DeveloperModeScreenViewModelAction { }

struct DeveloperModeScreenViewState: BindableState {
    var bindings: DeveloperModeScreenViewStateBindings
}

struct DeveloperModeScreenViewStateBindings {
    private let developerModeSettings: DeveloperModeSettings

    init(developerModeSettings: DeveloperModeSettings) {
        self.developerModeSettings = developerModeSettings
    }

    var showCustomHomeserver: Bool {
        get { developerModeSettings.showCustomHomeserver }
        set { developerModeSettings.showCustomHomeserver = newValue }
    }

    var showQRCodeLogin: Bool {
        get { developerModeSettings.showQRCodeLogin }
        set { developerModeSettings.showQRCodeLogin = newValue }
    }

    var groupSpaceChannels: Bool {
        get { developerModeSettings.groupSpaceChannels }
        set { developerModeSettings.groupSpaceChannels = newValue }
    }
}

enum DeveloperModeScreenViewAction { }
