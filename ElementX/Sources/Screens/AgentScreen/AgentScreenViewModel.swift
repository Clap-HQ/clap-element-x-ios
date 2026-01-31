//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

typealias AgentScreenViewModelType = StateStoreViewModelV2<AgentScreenViewState, AgentScreenViewAction>

class AgentScreenViewModel: AgentScreenViewModelType, AgentScreenViewModelProtocol {
    private let roomProxy: JoinedRoomProxyProtocol
    private let userSession: UserSessionProtocol
    
    private let actionsSubject: PassthroughSubject<AgentScreenViewModelAction, Never> = .init()
    var actionsPublisher: AnyPublisher<AgentScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(roomProxy: JoinedRoomProxyProtocol,
         userSession: UserSessionProtocol) {
        self.roomProxy = roomProxy
        self.userSession = userSession
        
        super.init(initialViewState: AgentScreenViewState(roomTitle: roomProxy.infoPublisher.value.displayName ?? roomProxy.id,
                                                          roomAvatar: roomProxy.infoPublisher.value.avatar),
                   mediaProvider: userSession.mediaProvider)
        
        roomProxy.infoPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] roomInfo in
                self?.updateRoomInfo(roomInfo)
            }
            .store(in: &cancellables)
        
        updateRoomInfo(roomProxy.infoPublisher.value)
    }
    
    // MARK: - Public
    
    override func process(viewAction: AgentScreenViewAction) {
        switch viewAction {
        case .dismiss:
            actionsSubject.send(.dismiss)
        }
    }
    
    func stop() {
        // Work around QLPreviewController dismissal issues, see the InteractiveQuickLookModifier.
        state.bindings.mediaPreviewViewModel = nil
    }
    
    func displayMediaPreview(_ mediaPreviewViewModel: TimelineMediaPreviewViewModel) {
        mediaPreviewViewModel.actions.sink { [weak self] action in
            guard let self else { return }
            switch action {
            case .viewInRoomTimeline, .displayMessageForwarding:
                break
            case .dismiss:
                state.bindings.mediaPreviewViewModel = nil
            }
        }
        .store(in: &cancellables)
        
        state.bindings.mediaPreviewViewModel = mediaPreviewViewModel
    }
    
    // MARK: - Private
    
    private func updateRoomInfo(_ roomInfo: RoomInfoProxyProtocol) {
        state.roomTitle = roomInfo.displayName ?? roomProxy.id
        state.roomAvatar = roomInfo.avatar
        if let powerLevels = roomInfo.powerLevels {
            state.canSendMessage = powerLevels.canOwnUser(sendMessage: .roomMessage)
        }
    }
}
