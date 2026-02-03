//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

enum AgentFlowCoordinatorAction {
    case dismiss
}

@MainActor
class AgentFlowCoordinator {
    private let userSession: UserSessionProtocol
    private let flowParameters: CommonFlowParameters
    private let navigationStackCoordinator: NavigationStackCoordinator
    
    private var agentScreenCoordinator: AgentScreenCoordinator?
    private var roomProxy: JoinedRoomProxyProtocol?
    private var timelineController: TimelineControllerProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    private let actionsSubject: PassthroughSubject<AgentFlowCoordinatorAction, Never> = .init()
    var actions: AnyPublisher<AgentFlowCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    var navigationStack: NavigationStackCoordinator { navigationStackCoordinator }
    var currentRoomID: String? { roomProxy?.id }
    
    init(userSession: UserSessionProtocol,
         flowParameters: CommonFlowParameters) {
        self.userSession = userSession
        self.flowParameters = flowParameters
        navigationStackCoordinator = NavigationStackCoordinator()
    }
    
    func presentAgentScreen(roomID: String) {
        guard agentScreenCoordinator == nil else { return }
        
        Task { @MainActor in
            guard agentScreenCoordinator == nil else { return }
            
            guard case let .joined(roomProxy) = await userSession.clientProxy.roomForIdentifier(roomID) else {
                MXLog.error("Failed to resolve Clap AI room: \(roomID)")
                return
            }
            
            await roomProxy.subscribeForUpdates()
            self.roomProxy = roomProxy
            
            let userID = userSession.clientProxy.userID
            let timelineItemFactory = RoomTimelineItemFactory(userID: userID,
                                                              attributedStringBuilder: AttributedStringBuilder(mentionBuilder: MentionBuilder()),
                                                              stateEventStringBuilder: RoomStateEventStringBuilder(userID: userID))
            let timelineController = flowParameters.timelineControllerFactory.buildTimelineController(roomProxy: roomProxy,
                                                                                                      initialFocussedEventID: nil,
                                                                                                      timelineItemFactory: timelineItemFactory,
                                                                                                      mediaProvider: userSession.mediaProvider)
            self.timelineController = timelineController
            
            let completionSuggestionService = CompletionSuggestionService(roomProxy: roomProxy,
                                                                          roomListPublisher: userSession.clientProxy.staticRoomSummaryProvider.roomListPublisher.eraseToAnyPublisher())
            let composerDraftService = ComposerDraftService(roomProxy: roomProxy,
                                                             timelineItemfactory: timelineItemFactory,
                                                             threadRootEventID: nil)
            
            let parameters = AgentScreenCoordinatorParameters(userSession: userSession,
                                                               roomProxy: roomProxy,
                                                               timelineController: timelineController,
                                                               mediaPlayerProvider: MediaPlayerProvider(),
                                                               emojiProvider: flowParameters.emojiProvider,
                                                               linkMetadataProvider: flowParameters.linkMetadataProvider,
                                                               completionSuggestionService: completionSuggestionService,
                                                               appMediator: flowParameters.appMediator,
                                                               appSettings: flowParameters.appSettings,
                                                               analytics: flowParameters.analytics,
                                                               composerDraftService: composerDraftService,
                                                               timelineControllerFactory: flowParameters.timelineControllerFactory,
                                                               userIndicatorController: flowParameters.userIndicatorController)
            
            let coordinator = AgentScreenCoordinator(parameters: parameters)
            
            coordinator.actions.sink { [weak self] action in
                guard let self else { return }
                handleAgentScreenAction(action)
            }
            .store(in: &cancellables)
            
            navigationStackCoordinator.setRootCoordinator(coordinator, animated: false)
            agentScreenCoordinator = coordinator
        }
    }
    
    func stop() {
        agentScreenCoordinator?.stop()
        agentScreenCoordinator = nil
        roomProxy = nil
        timelineController = nil
    }
    
    // MARK: - Action Routing
    
    private func handleAgentScreenAction(_ action: AgentScreenCoordinatorAction) {
        switch action {
        case .dismiss:
            actionsSubject.send(.dismiss)
        case .presentMediaUploadPicker(let mode):
            presentMediaUploadPicker(mode: mode)
        case .presentMediaUploadPreviewScreen(let mediaURLs):
            presentMediaUploadPreview(for: mediaURLs)
        case .presentMessageForwarding(let forwardingItem):
            presentMessageForwarding(with: forwardingItem)
        }
    }
    
    // MARK: - Media Upload
    
    private func presentMediaUploadPicker(mode: MediaPickerScreenMode) {
        let stackCoordinator = NavigationStackCoordinator()
        let mediaPickerCoordinator = MediaPickerScreenCoordinator(mode: mode,
                                                                   userIndicatorController: flowParameters.userIndicatorController,
                                                                   orientationManager: flowParameters.appMediator.windowManager) { [weak self] action in
            guard let self else { return }
            switch action {
            case .cancel:
                navigationStackCoordinator.setSheetCoordinator(nil)
            case .selectedMediaAtURLs(let urls):
                presentMediaUploadPreview(for: urls)
            }
        }
        stackCoordinator.setRootCoordinator(mediaPickerCoordinator)
        navigationStackCoordinator.setSheetCoordinator(stackCoordinator)
    }
    
    // MARK: - Message Forwarding
    
    private func presentMessageForwarding(with forwardingItem: MessageForwardingItem) {
        let stackCoordinator = NavigationStackCoordinator()
        
        let parameters = MessageForwardingScreenCoordinatorParameters(forwardingItem: forwardingItem,
                                                                       userSession: userSession,
                                                                       roomSummaryProvider: userSession.clientProxy.alternateRoomSummaryProvider,
                                                                       userIndicatorController: flowParameters.userIndicatorController)
        let coordinator = MessageForwardingScreenCoordinator(parameters: parameters)
        
        coordinator.actions.sink { [weak self] action in
            guard let self else { return }
            switch action {
            case .dismiss, .sent:
                navigationStackCoordinator.setSheetCoordinator(nil)
            }
        }
        .store(in: &cancellables)
        
        stackCoordinator.setRootCoordinator(coordinator)
        navigationStackCoordinator.setSheetCoordinator(stackCoordinator)
    }
    
    private func presentMediaUploadPreview(for mediaURLs: [URL]) {
        guard let timelineController else { return }
        
        let isEncrypted = roomProxy?.infoPublisher.value.isEncrypted ?? false
        let title: String? = mediaURLs.count == 1 ? mediaURLs.first?.lastPathComponent : nil
        
        let parameters = MediaUploadPreviewScreenCoordinatorParameters(mediaURLs: mediaURLs,
                                                                        title: title,
                                                                        isRoomEncrypted: isEncrypted,
                                                                        shouldShowCaptionWarning: flowParameters.appSettings.shouldShowMediaCaptionWarning,
                                                                        mediaUploadingPreprocessor: MediaUploadingPreprocessor(appSettings: flowParameters.appSettings),
                                                                        timelineController: timelineController,
                                                                        clientProxy: userSession.clientProxy,
                                                                        userIndicatorController: flowParameters.userIndicatorController)
        let previewCoordinator = MediaUploadPreviewScreenCoordinator(parameters: parameters)
        
        previewCoordinator.actions
            .sink { [weak self] action in
                switch action {
                case .dismiss:
                    self?.navigationStackCoordinator.setSheetCoordinator(nil)
                }
            }
            .store(in: &cancellables)
        
        let stackCoordinator = NavigationStackCoordinator()
        stackCoordinator.setRootCoordinator(previewCoordinator)
        navigationStackCoordinator.setSheetCoordinator(stackCoordinator)
    }
}
