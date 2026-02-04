//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

enum ScheduleFlowCoordinatorAction {
    case dismiss
}

@MainActor
class ScheduleFlowCoordinator {
    private let userSession: UserSessionProtocol
    private let userIndicatorController: UserIndicatorControllerProtocol
    private let navigationStackCoordinator: NavigationStackCoordinator
    
    private var cancellables = Set<AnyCancellable>()
    private weak var listCoordinator: ScheduleListScreenCoordinator?
    private var isAdmin = false
    
    private let actionsSubject = PassthroughSubject<ScheduleFlowCoordinatorAction, Never>()
    var actions: AnyPublisher<ScheduleFlowCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(userSession: UserSessionProtocol,
         userIndicatorController: UserIndicatorControllerProtocol,
         navigationStackCoordinator: NavigationStackCoordinator) {
        self.userSession = userSession
        self.userIndicatorController = userIndicatorController
        self.navigationStackCoordinator = navigationStackCoordinator
    }
    
    func start() {
        Task {
            let authResult = await userSession.clientProxy.clapAIAPI.ensureAuthenticated()
            if case .failure(let error) = authResult {
                MXLog.error("Failed to authenticate with Clap AI: \(error)")
            }
            
            let userResult = await userSession.clientProxy.clapAIAPI.fetchCurrentUser()
            if case .success(let user) = userResult {
                isAdmin = user.isAdmin
            }
            
            presentScheduleList()
        }
    }
    
    func stop() {
        cancellables.removeAll()
    }
    
    private func presentScheduleList() {
        let parameters = ScheduleListScreenCoordinatorParameters(
            scheduleAPI: userSession.clientProxy.clapAIAPI.schedules,
            userIndicatorController: userIndicatorController,
            isAdmin: isAdmin
        )
        
        let coordinator = ScheduleListScreenCoordinator(parameters: parameters)
        listCoordinator = coordinator
        
        coordinator.actions
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .showScheduleDetail(let schedule):
                    presentScheduleDetail(schedule)
                case .showCreateSchedule:
                    presentCreateSchedule()
                }
            }
            .store(in: &cancellables)
        
        navigationStackCoordinator.push(coordinator)
    }
    
    private func presentScheduleDetail(_ schedule: Schedule) {
        let parameters = ScheduleDetailScreenCoordinatorParameters(
            schedule: schedule,
            scheduleAPI: userSession.clientProxy.clapAIAPI.schedules,
            userIndicatorController: userIndicatorController,
            isAdmin: isAdmin
        )
        
        let coordinator = ScheduleDetailScreenCoordinator(parameters: parameters)
        
        coordinator.actions
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .dismiss:
                    navigationStackCoordinator.pop()
                case .deleted:
                    navigationStackCoordinator.pop()
                    listCoordinator?.reload()
                }
            }
            .store(in: &cancellables)
        
        navigationStackCoordinator.push(coordinator)
    }
    
    private func presentCreateSchedule() {
        let rooms = userSession.clientProxy.roomSummaryProvider.roomListPublisher.value
        
        let parameters = ScheduleCreateScreenCoordinatorParameters(
            scheduleAPI: userSession.clientProxy.clapAIAPI.schedules,
            userID: userSession.clientProxy.userID,
            rooms: rooms,
            userIndicatorController: userIndicatorController
        )
        
        let coordinator = ScheduleCreateScreenCoordinator(parameters: parameters)
        
        coordinator.actions
            .sink { [weak self] action in
                guard let self else { return }
                
                navigationStackCoordinator.setSheetCoordinator(nil)
                
                switch action {
                case .created:
                    listCoordinator?.reload()
                case .dismiss:
                    break
                }
            }
            .store(in: &cancellables)
        
        let sheetCoordinator = NavigationStackCoordinator()
        sheetCoordinator.setRootCoordinator(coordinator)
        navigationStackCoordinator.setSheetCoordinator(sheetCoordinator)
    }
}
