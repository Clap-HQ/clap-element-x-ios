//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation

@MainActor
protocol CreateRoomInSpaceScreenViewModelProtocol {
    var actions: AnyPublisher<CreateRoomInSpaceScreenViewModelAction, Never> { get }
    var context: CreateRoomInSpaceScreenViewModelType.Context { get }

    func updateAvatar(fileURL: URL)
}
