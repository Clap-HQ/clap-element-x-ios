//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

struct SpaceDetailScreenCoordinatorParameters {
    let spaceRoomListProxy: SpaceRoomListProxyProtocol
    let spaceServiceProxy: SpaceServiceProxyProtocol
    let userSession: UserSessionProtocol
    let appSettings: AppSettings
    let userIndicatorController: UserIndicatorControllerProtocol
}

enum SpaceDetailScreenCoordinatorAction {
    case selectRoom(roomID: String)
    case showRoomDetails(roomID: String)
    case dismiss
    case displayMembers(roomProxy: JoinedRoomProxyProtocol)
    case inviteUsers(roomProxy: JoinedRoomProxyProtocol)
    case displaySpaceSettings(roomProxy: JoinedRoomProxyProtocol)
    case presentCreateRoomInSpace(spaceID: String, spaceName: String)
    case removedRoomFromSpace(spaceID: String)
    case leftSpace
}

final class SpaceDetailScreenCoordinator: CoordinatorProtocol {
    private let parameters: SpaceDetailScreenCoordinatorParameters
    private let shouldShowJoinAllRoomsConfirmation: Bool
    private var viewModel: SpaceDetailScreenViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    private let actionsSubject: PassthroughSubject<SpaceDetailScreenCoordinatorAction, Never> = .init()
    var actionsPublisher: AnyPublisher<SpaceDetailScreenCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(parameters: SpaceDetailScreenCoordinatorParameters, shouldShowJoinAllRoomsConfirmation: Bool = false) {
        self.parameters = parameters
        self.shouldShowJoinAllRoomsConfirmation = shouldShowJoinAllRoomsConfirmation
        viewModel = SpaceDetailScreenViewModel(spaceRoomListProxy: parameters.spaceRoomListProxy,
                                               spaceServiceProxy: parameters.spaceServiceProxy,
                                               userSession: parameters.userSession,
                                               appSettings: parameters.appSettings,
                                               userIndicatorController: parameters.userIndicatorController,
                                               shouldShowJoinAllRoomsConfirmation: shouldShowJoinAllRoomsConfirmation)
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
                case .inviteUsers(let roomProxy):
                    actionsSubject.send(.inviteUsers(roomProxy: roomProxy))
                case .displaySpaceSettings(let roomProxy):
                    actionsSubject.send(.displaySpaceSettings(roomProxy: roomProxy))
                case .presentCreateRoomInSpace(let spaceID, let spaceName):
                    actionsSubject.send(.presentCreateRoomInSpace(spaceID: spaceID, spaceName: spaceName))
                case .removedRoomFromSpace(let spaceID):
                    actionsSubject.send(.removedRoomFromSpace(spaceID: spaceID))
                case .leftSpace:
                    actionsSubject.send(.leftSpace)
                }
            }
            .store(in: &cancellables)
    }

    func toPresentable() -> AnyView {
        AnyView(SpaceDetailScreen(context: viewModel.context))
    }

    func refreshSpaceChildren() async {
        await viewModel.refreshSpaceChildren()
    }
}
