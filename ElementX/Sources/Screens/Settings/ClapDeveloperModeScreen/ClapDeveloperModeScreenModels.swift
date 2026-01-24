//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation

enum ClapDeveloperModeScreenViewModelAction { }

struct ClapDeveloperModeScreenViewState: BindableState {
    var bindings: ClapDeveloperModeScreenViewStateBindings
}

struct ClapDeveloperModeScreenViewStateBindings {
    private let clapDeveloperModeSettings: ClapDeveloperModeSettings

    init(clapDeveloperModeSettings: ClapDeveloperModeSettings) {
        self.clapDeveloperModeSettings = clapDeveloperModeSettings
    }

    var showCustomHomeserver: Bool {
        get { clapDeveloperModeSettings.showCustomHomeserver }
        set { clapDeveloperModeSettings.showCustomHomeserver = newValue }
    }

    var showQRCodeLogin: Bool {
        get { clapDeveloperModeSettings.showQRCodeLogin }
        set { clapDeveloperModeSettings.showQRCodeLogin = newValue }
    }

    var groupSpaceRooms: Bool {
        get { clapDeveloperModeSettings.groupSpaceRooms }
        set { clapDeveloperModeSettings.groupSpaceRooms = newValue }
    }

    var showDeveloperSettings: Bool {
        get { clapDeveloperModeSettings.showDeveloperSettings }
        set { clapDeveloperModeSettings.showDeveloperSettings = newValue }
    }
}

enum ClapDeveloperModeScreenViewAction { }
