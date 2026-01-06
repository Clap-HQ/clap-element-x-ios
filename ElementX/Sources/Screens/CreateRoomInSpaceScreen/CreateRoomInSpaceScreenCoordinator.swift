//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

struct CreateRoomInSpaceScreenCoordinatorParameters {
    let spaceID: String
    let spaceName: String
    let userSession: UserSessionProtocol
    let userIndicatorController: UserIndicatorControllerProtocol
    let appSettings: AppSettings
}

enum CreateRoomInSpaceScreenCoordinatorAction {
    case createdRoom(roomID: String)
    case dismiss
    case displayMediaPickerWithMode(MediaPickerScreenMode)
}

final class CreateRoomInSpaceScreenCoordinator: CoordinatorProtocol {
    private var viewModel: CreateRoomInSpaceScreenViewModelProtocol
    private let actionsSubject: PassthroughSubject<CreateRoomInSpaceScreenCoordinatorAction, Never> = .init()
    private var cancellables = Set<AnyCancellable>()

    var actions: AnyPublisher<CreateRoomInSpaceScreenCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(parameters: CreateRoomInSpaceScreenCoordinatorParameters) {
        viewModel = CreateRoomInSpaceScreenViewModel(spaceID: parameters.spaceID,
                                                      spaceName: parameters.spaceName,
                                                      userSession: parameters.userSession,
                                                      userIndicatorController: parameters.userIndicatorController,
                                                      appSettings: parameters.appSettings)
    }

    func start() {
        viewModel.actions.sink { [weak self] action in
            guard let self else { return }
            switch action {
            case .createdRoom(let roomID):
                actionsSubject.send(.createdRoom(roomID: roomID))
            case .dismiss:
                actionsSubject.send(.dismiss)
            case .displayCameraPicker:
                actionsSubject.send(.displayMediaPickerWithMode(.init(source: .camera, selectionType: .single)))
            case .displayMediaPicker:
                actionsSubject.send(.displayMediaPickerWithMode(.init(source: .photoLibrary, selectionType: .single)))
            }
        }
        .store(in: &cancellables)
    }

    func toPresentable() -> AnyView {
        AnyView(CreateRoomInSpaceScreen(context: viewModel.context))
    }

    func updateAvatar(fileURL: URL) {
        viewModel.updateAvatar(fileURL: fileURL)
    }
}
