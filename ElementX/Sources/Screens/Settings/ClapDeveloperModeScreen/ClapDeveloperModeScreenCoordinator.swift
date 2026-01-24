//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

final class ClapDeveloperModeScreenCoordinator: CoordinatorProtocol {
    private var viewModel: ClapDeveloperModeScreenViewModelProtocol

    init(clapDeveloperModeSettings: ClapDeveloperModeSettings) {
        viewModel = ClapDeveloperModeScreenViewModel(clapDeveloperModeSettings: clapDeveloperModeSettings)
    }

    func toPresentable() -> AnyView {
        AnyView(ClapDeveloperModeScreen(context: viewModel.context))
    }
}
