//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

typealias JoinAllRoomsConfirmationViewModelType = StateStoreViewModelV2<JoinAllRoomsConfirmationViewState, JoinAllRoomsConfirmationViewAction>

class JoinAllRoomsConfirmationViewModel: JoinAllRoomsConfirmationViewModelType {
    let actionsSubject = PassthroughSubject<JoinAllRoomsConfirmationViewModelAction, Never>()
    var actions: AnyPublisher<JoinAllRoomsConfirmationViewModelAction, Never> { actionsSubject.eraseToAnyPublisher() }

    init(spaceID: String, spaceName: String) {
        super.init(initialViewState: JoinAllRoomsConfirmationViewState(spaceID: spaceID, spaceName: spaceName))
    }

    override func process(viewAction: JoinAllRoomsConfirmationViewAction) {
        switch viewAction {
        case .confirm:
            actionsSubject.send(.confirm)
        case .cancel:
            actionsSubject.send(.cancel)
        }
    }
}

extension JoinAllRoomsConfirmationViewModel: Identifiable {
    var id: String { state.spaceID }
}
