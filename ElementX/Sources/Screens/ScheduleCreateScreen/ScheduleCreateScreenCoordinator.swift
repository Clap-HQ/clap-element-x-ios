//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

struct ScheduleCreateScreenCoordinatorParameters {
    let scheduleAPI: ClapAIScheduleAPIProtocol
    let userID: String
    let rooms: [RoomSummary]
    let userIndicatorController: UserIndicatorControllerProtocol
}

enum ScheduleCreateScreenCoordinatorAction {
    case dismiss
    case created(Schedule)
}

final class ScheduleCreateScreenCoordinator: CoordinatorProtocol {
    private let parameters: ScheduleCreateScreenCoordinatorParameters
    private let viewModel: ScheduleCreateScreenViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    private let actionsSubject = PassthroughSubject<ScheduleCreateScreenCoordinatorAction, Never>()
    var actions: AnyPublisher<ScheduleCreateScreenCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(parameters: ScheduleCreateScreenCoordinatorParameters) {
        self.parameters = parameters
        viewModel = ScheduleCreateScreenViewModel(
            scheduleAPI: parameters.scheduleAPI,
            userID: parameters.userID,
            rooms: parameters.rooms,
            userIndicatorController: parameters.userIndicatorController
        )
    }
    
    func start() {
        viewModel.actions
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .dismiss:
                    actionsSubject.send(.dismiss)
                case .created(let schedule):
                    actionsSubject.send(.created(schedule))
                }
            }
            .store(in: &cancellables)
    }
    
    func stop() {
        cancellables.removeAll()
    }
    
    func toPresentable() -> AnyView {
        AnyView(ScheduleCreateScreen(context: viewModel.context))
    }
}
