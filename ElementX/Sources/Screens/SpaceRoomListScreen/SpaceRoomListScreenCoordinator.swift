//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

struct SpaceRoomListScreenCoordinatorParameters {
    let spaceRoomListProxy: SpaceRoomListProxyProtocol
    let spaceServiceProxy: SpaceServiceProxyProtocol
    let userSession: UserSessionProtocol
    let appSettings: AppSettings
    let userIndicatorController: UserIndicatorControllerProtocol
}

enum SpaceRoomListScreenCoordinatorAction {
    case selectRoom(roomID: String)
    case showRoomDetails(roomID: String)
    case dismiss
    case displayMembers(roomProxy: JoinedRoomProxyProtocol)
    case displaySpaceSettings(roomProxy: JoinedRoomProxyProtocol)
    case leftSpace
}

final class SpaceRoomListScreenCoordinator: CoordinatorProtocol {
    private let parameters: SpaceRoomListScreenCoordinatorParameters
    private var viewModel: SpaceRoomListScreenViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    private let actionsSubject: PassthroughSubject<SpaceRoomListScreenCoordinatorAction, Never> = .init()
    var actionsPublisher: AnyPublisher<SpaceRoomListScreenCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(parameters: SpaceRoomListScreenCoordinatorParameters) {
        self.parameters = parameters
        viewModel = SpaceRoomListScreenViewModel(spaceRoomListProxy: parameters.spaceRoomListProxy,
                                                 spaceServiceProxy: parameters.spaceServiceProxy,
                                                 userSession: parameters.userSession,
                                                 appSettings: parameters.appSettings,
                                                 userIndicatorController: parameters.userIndicatorController)
    }

    func start() {
        viewModel.actionsPublisher
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .selectRoom(let roomID):
                    actionsSubject.send(.selectRoom(roomID: roomID))
                case .showRoomDetails(let roomID):
                    actionsSubject.send(.showRoomDetails(roomID: roomID))
                case .dismiss:
                    actionsSubject.send(.dismiss)
                case .displayMembers(let roomProxy):
                    actionsSubject.send(.displayMembers(roomProxy: roomProxy))
                case .displaySpaceSettings(let roomProxy):
                    actionsSubject.send(.displaySpaceSettings(roomProxy: roomProxy))
                case .leftSpace:
                    actionsSubject.send(.leftSpace)
                }
            }
            .store(in: &cancellables)
    }

    func toPresentable() -> AnyView {
        AnyView(SpaceRoomListScreen(context: viewModel.context))
    }
}
