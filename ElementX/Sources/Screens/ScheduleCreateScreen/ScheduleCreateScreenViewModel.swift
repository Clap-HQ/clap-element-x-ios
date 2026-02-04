//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation

typealias ScheduleCreateScreenViewModelType = StateStoreViewModelV2<ScheduleCreateScreenViewState, ScheduleCreateScreenViewAction>

class ScheduleCreateScreenViewModel: ScheduleCreateScreenViewModelType, ScheduleCreateScreenViewModelProtocol {
    private let scheduleAPI: ClapAIScheduleAPIProtocol
    private let userID: String
    private let userIndicatorController: UserIndicatorControllerProtocol
    
    private let actionsSubject = PassthroughSubject<ScheduleCreateScreenViewModelAction, Never>()
    var actions: AnyPublisher<ScheduleCreateScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(scheduleAPI: ClapAIScheduleAPIProtocol,
         userID: String,
         rooms: [RoomSummary],
         userIndicatorController: UserIndicatorControllerProtocol) {
        self.scheduleAPI = scheduleAPI
        self.userID = userID
        self.userIndicatorController = userIndicatorController
        
        var initialViewState = ScheduleCreateScreenViewState()
        initialViewState.rooms = rooms.filter { !$0.isDirect }
        initialViewState.directMessages = rooms.filter { $0.isDirect }
        super.init(initialViewState: initialViewState)
    }
    
    override func process(viewAction: ScheduleCreateScreenViewAction) {
        switch viewAction {
        case .selectRoom(let room):
            state.bindings.selectedRoom = room
            state.bindings.showRoomPicker = false
        case .showRoomPicker:
            state.bindings.showRoomPicker = true
        case .hideRoomPicker:
            state.bindings.showRoomPicker = false
        case .submit:
            Task { await submit() }
        case .cancel:
            actionsSubject.send(.dismiss)
        }
    }
    
    private func submit() async {
        guard let selectedRoom = state.bindings.selectedRoom else { return }
        
        state.isSubmitting = true
        showLoadingIndicator(L10n.screenScheduleLoadingCreate)
        
        let result = await scheduleAPI.createSchedule(
            name: state.bindings.name,
            roomID: selectedRoom.id,
            cronExpression: state.bindings.cronExpression,
            timezone: state.bindings.selectedTimezone.rawValue,
            prompt: state.bindings.prompt,
            userID: userID
        )
        
        hideLoadingIndicator()
        state.isSubmitting = false
        
        switch result {
        case .success(let schedule):
            showSuccessIndicator(L10n.screenScheduleSuccessCreated)
            actionsSubject.send(.created(schedule))
        case .failure(let error):
            MXLog.error("Failed to create schedule: \(error)")
            showError(L10n.screenScheduleErrorCreateFailed)
        }
    }
    
    private func showLoadingIndicator(_ message: String) {
        userIndicatorController.submitIndicator(
            UserIndicator(id: "scheduleCreateLoading", type: .modal, title: message, persistent: true)
        )
    }
    
    private func hideLoadingIndicator() {
        userIndicatorController.retractIndicatorWithId("scheduleCreateLoading")
    }
    
    private func showSuccessIndicator(_ message: String) {
        userIndicatorController.submitIndicator(
            UserIndicator(id: "scheduleCreateSuccess", type: .toast, title: message)
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
