//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

struct ScheduleDetailScreenCoordinatorParameters {
    let schedule: Schedule
    let scheduleAPI: ClapAIScheduleAPIProtocol
    let userIndicatorController: UserIndicatorControllerProtocol
    var isAdmin: Bool = false
}

enum ScheduleDetailScreenCoordinatorAction {
    case dismiss
    case deleted
}

final class ScheduleDetailScreenCoordinator: CoordinatorProtocol {
    private let parameters: ScheduleDetailScreenCoordinatorParameters
    private let viewModel: ScheduleDetailScreenViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    private let actionsSubject = PassthroughSubject<ScheduleDetailScreenCoordinatorAction, Never>()
    var actions: AnyPublisher<ScheduleDetailScreenCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(parameters: ScheduleDetailScreenCoordinatorParameters) {
        self.parameters = parameters
        viewModel = ScheduleDetailScreenViewModel(
            schedule: parameters.schedule,
            scheduleAPI: parameters.scheduleAPI,
            userIndicatorController: parameters.userIndicatorController,
            isAdmin: parameters.isAdmin
        )
    }
    
    func start() {
        viewModel.actions
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .dismiss:
                    actionsSubject.send(.dismiss)
                case .deleted:
                    actionsSubject.send(.deleted)
                }
            }
            .store(in: &cancellables)
    }
    
    func stop() {
        cancellables.removeAll()
    }
    
    func toPresentable() -> AnyView {
        AnyView(ScheduleDetailScreen(context: viewModel.context))
    }
}
