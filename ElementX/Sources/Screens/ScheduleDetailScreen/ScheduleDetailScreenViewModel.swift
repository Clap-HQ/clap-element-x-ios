//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation

typealias ScheduleDetailScreenViewModelType = StateStoreViewModelV2<ScheduleDetailScreenViewState, ScheduleDetailScreenViewAction>

class ScheduleDetailScreenViewModel: ScheduleDetailScreenViewModelType, ScheduleDetailScreenViewModelProtocol {
    private let scheduleAPI: ClapAIScheduleAPIProtocol
    private let userIndicatorController: UserIndicatorControllerProtocol
    
    private let actionsSubject = PassthroughSubject<ScheduleDetailScreenViewModelAction, Never>()
    var actions: AnyPublisher<ScheduleDetailScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(schedule: Schedule,
         scheduleAPI: ClapAIScheduleAPIProtocol,
         userIndicatorController: UserIndicatorControllerProtocol,
         isAdmin: Bool = false) {
        self.scheduleAPI = scheduleAPI
        self.userIndicatorController = userIndicatorController
        
        var initialState = ScheduleDetailScreenViewState(schedule: schedule)
        initialState.isAdmin = isAdmin
        super.init(initialViewState: initialState)
        
        Task { await loadHistory() }
    }
    
    private func loadHistory() async {
        state.isLoadingHistory = true
        
        let result = await scheduleAPI.getScheduleHistory(scheduleID: state.schedule.id, limit: 20)
        
        switch result {
        case .success(let history):
            state.history = history
        case .failure(let error):
            MXLog.error("Failed to load schedule history: \(error)")
        }
        state.isLoadingHistory = false
    }
    
    override func process(viewAction: ScheduleDetailScreenViewAction) {
        switch viewAction {
        case .delete:
            state.bindings.alertInfo = AlertInfo(
                id: .deleteConfirmation,
                title: L10n.screenScheduleDeleteTitle,
                message: L10n.screenScheduleDeleteMessage(state.schedule.name),
                primaryButton: .init(title: L10n.screenScheduleDeleteAction, role: .destructive) { [weak self] in
                    self?.process(viewAction: .confirmDelete)
                },
                secondaryButton: .init(title: L10n.actionCancel, role: .cancel, action: nil)
            )
        case .confirmDelete:
            Task { await deleteSchedule() }
        case .run:
            Task { await runSchedule() }
        case .pause:
            Task { await pauseSchedule() }
        case .resume:
            Task { await resumeSchedule() }
        }
    }
    
    private func deleteSchedule() async {
        showLoadingIndicator(L10n.screenScheduleLoadingDelete)
        
        let result = await scheduleAPI.deleteSchedule(id: state.schedule.id)
        
        hideLoadingIndicator()
        
        switch result {
        case .success:
            showSuccessIndicator(L10n.screenScheduleSuccessDeleted)
            actionsSubject.send(.deleted)
        case .failure(let error):
            MXLog.error("Failed to delete schedule: \(error)")
            showError(L10n.screenScheduleErrorDeleteFailed)
        }
    }
    
    private func runSchedule() async {
        showLoadingIndicator(L10n.screenScheduleLoadingRun)
        
        let result = await scheduleAPI.runSchedule(id: state.schedule.id)
        
        hideLoadingIndicator()
        
        switch result {
        case .success:
            showSuccessIndicator(L10n.screenScheduleSuccessRun)
            Task { await loadHistory() }
        case .failure(let error):
            MXLog.error("Failed to run schedule: \(error)")
            showError(L10n.screenScheduleErrorRunFailed)
        }
    }
    
    private func pauseSchedule() async {
        showLoadingIndicator(L10n.screenScheduleLoadingPause)
        
        let result = await scheduleAPI.pauseSchedule(id: state.schedule.id)
        
        hideLoadingIndicator()
        
        switch result {
        case .success(let updatedSchedule):
            state.schedule = updatedSchedule
            showSuccessIndicator(L10n.screenScheduleSuccessPaused)
        case .failure(let error):
            MXLog.error("Failed to pause schedule: \(error)")
            showError(L10n.screenScheduleErrorPauseFailed)
        }
    }
    
    private func resumeSchedule() async {
        showLoadingIndicator(L10n.screenScheduleLoadingResume)
        
        let result = await scheduleAPI.resumeSchedule(id: state.schedule.id)
        
        hideLoadingIndicator()
        
        switch result {
        case .success(let updatedSchedule):
            state.schedule = updatedSchedule
            showSuccessIndicator(L10n.screenScheduleSuccessResumed)
        case .failure(let error):
            MXLog.error("Failed to resume schedule: \(error)")
            showError(L10n.screenScheduleErrorResumeFailed)
        }
    }
    
    private func showLoadingIndicator(_ message: String) {
        userIndicatorController.submitIndicator(
            UserIndicator(id: "scheduleDetailLoading", type: .modal, title: message, persistent: true)
        )
    }
    
    private func hideLoadingIndicator() {
        userIndicatorController.retractIndicatorWithId("scheduleDetailLoading")
    }
    
    private func showSuccessIndicator(_ message: String) {
        userIndicatorController.submitIndicator(
            UserIndicator(id: "scheduleDetailSuccess", type: .toast, title: message)
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
