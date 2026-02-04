//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation

typealias ScheduleListScreenViewModelType = StateStoreViewModelV2<ScheduleListScreenViewState, ScheduleListScreenViewAction>

class ScheduleListScreenViewModel: ScheduleListScreenViewModelType, ScheduleListScreenViewModelProtocol {
    private let scheduleAPI: ClapAIScheduleAPIProtocol
    private let userIndicatorController: UserIndicatorControllerProtocol
    
    private let actionsSubject = PassthroughSubject<ScheduleListScreenViewModelAction, Never>()
    var actions: AnyPublisher<ScheduleListScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(scheduleAPI: ClapAIScheduleAPIProtocol,
         userIndicatorController: UserIndicatorControllerProtocol,
         isAdmin: Bool) {
        self.scheduleAPI = scheduleAPI
        self.userIndicatorController = userIndicatorController
        
        var initialState = ScheduleListScreenViewState()
        initialState.isAdmin = isAdmin
        super.init(initialViewState: initialState)
        
        Task {
            await loadSchedules()
        }
    }
    
    override func process(viewAction: ScheduleListScreenViewAction) {
        switch viewAction {
        case .refresh:
            Task { await loadSchedules() }
        case .selectSchedule(let schedule):
            actionsSubject.send(.showScheduleDetail(schedule))
        case .deleteSchedule(let schedule):
            state.bindings.alertInfo = AlertInfo(
                id: .deleteConfirmation(schedule),
                title: L10n.screenScheduleDeleteTitle,
                message: L10n.screenScheduleDeleteMessage(schedule.name),
                primaryButton: .init(title: L10n.screenScheduleDeleteAction, role: .destructive) { [weak self] in
                    self?.process(viewAction: .confirmDelete(schedule))
                },
                secondaryButton: .init(title: L10n.actionCancel, role: .cancel, action: nil)
            )
        case .confirmDelete(let schedule):
            Task { await deleteSchedule(schedule) }
        case .createSchedule:
            actionsSubject.send(.showCreateSchedule)
        }
    }
    
    private func loadSchedules() async {
        let result = await scheduleAPI.listSchedules()
        
        switch result {
        case .success(let schedules):
            state.schedules = schedules
            state.isLoading = false
        case .failure(let error):
            MXLog.error("Failed to load schedules: \(error)")
            state.isLoading = false
            showError(L10n.screenScheduleErrorLoadFailed)
        }
    }
    
    private func deleteSchedule(_ schedule: Schedule) async {
        showLoadingIndicator(L10n.screenScheduleLoadingDelete)
        
        let result = await scheduleAPI.deleteSchedule(id: schedule.id)
        
        hideLoadingIndicator()
        
        switch result {
        case .success:
            showSuccessIndicator(L10n.screenScheduleSuccessDeleted)
            await loadSchedules()
        case .failure(let error):
            MXLog.error("Failed to delete schedule: \(error)")
            showError(L10n.screenScheduleErrorDeleteFailed)
        }
    }
    
    private func showLoadingIndicator(_ message: String) {
        userIndicatorController.submitIndicator(
            UserIndicator(id: "scheduleLoading", type: .modal, title: message, persistent: true)
        )
    }
    
    private func hideLoadingIndicator() {
        userIndicatorController.retractIndicatorWithId("scheduleLoading")
    }
    
    private func showSuccessIndicator(_ message: String) {
        userIndicatorController.submitIndicator(
            UserIndicator(id: "scheduleSuccess", type: .toast, title: message)
        )
    }
    
    private func showError(_ message: String) {
        state.bindings.alertInfo = AlertInfo(
            id: .error(message),
            title: L10n.commonErrorTitle,
            message: message
        )
    }
}
