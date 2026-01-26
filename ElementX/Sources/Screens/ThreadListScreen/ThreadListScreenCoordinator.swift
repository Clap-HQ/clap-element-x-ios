//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

struct ThreadListScreenCoordinatorParameters {
    let roomProxy: JoinedRoomProxyProtocol
    let threadsAPI: MatrixThreadsAPIProtocol
    let mediaProvider: MediaProviderProtocol
}

final class ThreadListScreenCoordinator: CoordinatorProtocol {
    private let parameters: ThreadListScreenCoordinatorParameters
    private let viewModel: ThreadListScreenViewModelProtocol

    private var cancellables = Set<AnyCancellable>()

    private let actionsSubject: PassthroughSubject<ThreadListScreenCoordinatorAction, Never> = .init()
    var actions: AnyPublisher<ThreadListScreenCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(parameters: ThreadListScreenCoordinatorParameters) {
        self.parameters = parameters
        viewModel = ThreadListScreenViewModel(roomProxy: parameters.roomProxy,
                                              threadsAPI: parameters.threadsAPI,
                                              mediaProvider: parameters.mediaProvider)
    }

    func start() {
        viewModel.actionsPublisher
            .sink { [weak self] action in
                guard let self else { return }

                switch action {
                case .dismiss:
                    actionsSubject.send(.dismiss)
                case .selectThread(let rootEventID):
                    actionsSubject.send(.selectThread(rootEventID: rootEventID))
                }
            }
            .store(in: &cancellables)
    }

    func toPresentable() -> AnyView {
        AnyView(ThreadListScreen(context: viewModel.context))
    }
}
