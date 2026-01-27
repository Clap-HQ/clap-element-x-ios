//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine

@MainActor
protocol SpaceDetailScreenViewModelProtocol {
    var actionsPublisher: AnyPublisher<SpaceDetailScreenViewModelAction, Never> { get }
    var context: SpaceDetailScreenViewModel.Context { get }

    func refreshSpaceChildren() async
}
