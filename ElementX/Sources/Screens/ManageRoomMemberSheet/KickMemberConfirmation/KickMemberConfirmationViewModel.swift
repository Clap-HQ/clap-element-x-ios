//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

typealias KickMemberConfirmationViewModelType = StateStoreViewModelV2<KickMemberConfirmationViewState, KickMemberConfirmationViewAction>

class KickMemberConfirmationViewModel: KickMemberConfirmationViewModelType {
    private let actionsSubject = PassthroughSubject<KickMemberConfirmationViewModelAction, Never>()
    var actions: AnyPublisher<KickMemberConfirmationViewModelAction, Never> { actionsSubject.eraseToAnyPublisher() }

    init(memberID: String, memberName: String?) {
        super.init(initialViewState: KickMemberConfirmationViewState(memberID: memberID, memberName: memberName))
    }

    override func process(viewAction: KickMemberConfirmationViewAction) {
        switch viewAction {
        case .confirm:
            actionsSubject.send(.confirm(removeFromAllRooms: state.removeFromAllRooms))
        case .cancel:
            actionsSubject.send(.cancel)
        case .toggleRemoveFromAllRooms:
            state.removeFromAllRooms.toggle()
        }
    }
}

extension KickMemberConfirmationViewModel: Identifiable {
    var id: String { state.memberID }
}
