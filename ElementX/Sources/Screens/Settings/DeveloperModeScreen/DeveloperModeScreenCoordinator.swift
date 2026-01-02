//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

final class DeveloperModeScreenCoordinator: CoordinatorProtocol {
    private var viewModel: DeveloperModeScreenViewModelProtocol

    init(developerModeSettings: DeveloperModeSettings) {
        viewModel = DeveloperModeScreenViewModel(developerModeSettings: developerModeSettings)
    }

    func toPresentable() -> AnyView {
        AnyView(DeveloperModeScreen(context: viewModel.context))
    }
}
