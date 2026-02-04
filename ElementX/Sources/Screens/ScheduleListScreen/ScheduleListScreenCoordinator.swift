//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

struct ScheduleListScreenCoordinatorParameters {
    let scheduleAPI: ClapAIScheduleAPIProtocol
    let userIndicatorController: UserIndicatorControllerProtocol
    let isAdmin: Bool
}

enum ScheduleListScreenCoordinatorAction {
    case showScheduleDetail(Schedule)
    case showCreateSchedule
}

final class ScheduleListScreenCoordinator: CoordinatorProtocol {
    private let parameters: ScheduleListScreenCoordinatorParameters
    private let viewModel: ScheduleListScreenViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    private let actionsSubject = PassthroughSubject<ScheduleListScreenCoordinatorAction, Never>()
    var actions: AnyPublisher<ScheduleListScreenCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(parameters: ScheduleListScreenCoordinatorParameters) {
        self.parameters = parameters
        viewModel = ScheduleListScreenViewModel(
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
                case .showScheduleDetail(let schedule):
                    actionsSubject.send(.showScheduleDetail(schedule))
                case .showCreateSchedule:
                    actionsSubject.send(.showCreateSchedule)
                }
            }
            .store(in: &cancellables)
    }
    
    func stop() {
        cancellables.removeAll()
    }
    
    func reload() {
        viewModel.process(viewAction: .refresh)
    }
    
    func toPresentable() -> AnyView {
        AnyView(ScheduleListScreen(context: viewModel.context))
    }
}
