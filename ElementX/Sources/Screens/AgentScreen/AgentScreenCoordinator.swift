//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI
import WysiwygComposer

struct AgentScreenCoordinatorParameters {
    let userSession: UserSessionProtocol
    let roomProxy: JoinedRoomProxyProtocol
    let timelineController: TimelineControllerProtocol
    let mediaPlayerProvider: MediaPlayerProviderProtocol
    let emojiProvider: EmojiProviderProtocol
    let linkMetadataProvider: LinkMetadataProviderProtocol
    let completionSuggestionService: CompletionSuggestionServiceProtocol
    let appMediator: AppMediatorProtocol
    let appSettings: AppSettings
    let analytics: AnalyticsService
    let composerDraftService: ComposerDraftServiceProtocol
    let timelineControllerFactory: TimelineControllerFactoryProtocol
    let userIndicatorController: UserIndicatorControllerProtocol
}

enum AgentScreenCoordinatorAction {
    case dismiss
    case presentMediaUploadPicker(mode: MediaPickerScreenMode)
    case presentMediaUploadPreviewScreen(mediaURLs: [URL])
    case presentMessageForwarding(forwardingItem: MessageForwardingItem)
}

final class AgentScreenCoordinator: CoordinatorProtocol {
    private let parameters: AgentScreenCoordinatorParameters
    private let viewModel: AgentScreenViewModelProtocol
    private let timelineViewModel: TimelineViewModelProtocol
    private var composerViewModel: ComposerToolbarViewModelProtocol
    
    private var cancellables = Set<AnyCancellable>()

    private let actionsSubject: PassthroughSubject<AgentScreenCoordinatorAction, Never> = .init()
    var actions: AnyPublisher<AgentScreenCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(parameters: AgentScreenCoordinatorParameters) {
        self.parameters = parameters
        
        viewModel = AgentScreenViewModel(roomProxy: parameters.roomProxy, userSession: parameters.userSession)
        
        timelineViewModel = TimelineViewModel(roomProxy: parameters.roomProxy,
                                              focussedEventID: nil,
                                              timelineController: parameters.timelineController,
                                              userSession: parameters.userSession,
                                              mediaPlayerProvider: parameters.mediaPlayerProvider,
                                              userIndicatorController: parameters.userIndicatorController,
                                              appMediator: parameters.appMediator,
                                              appSettings: parameters.appSettings,
                                              analyticsService: parameters.analytics,
                                              emojiProvider: parameters.emojiProvider,
                                              linkMetadataProvider: parameters.linkMetadataProvider,
                                              timelineControllerFactory: parameters.timelineControllerFactory)
        
        let wysiwygViewModel = WysiwygComposerViewModel(minHeight: ComposerConstant.minHeight,
                                                         maxCompressedHeight: ComposerConstant.maxHeight,
                                                         maxExpandedHeight: ComposerConstant.maxHeight,
                                                         parserStyle: .elementX)
        
        let composerVM = ComposerToolbarViewModel(initialText: nil,
                                                     roomProxy: parameters.roomProxy,
                                                     wysiwygViewModel: wysiwygViewModel,
                                                     completionSuggestionService: parameters.completionSuggestionService,
                                                     mediaProvider: parameters.userSession.mediaProvider,
                                                     mentionDisplayHelper: ComposerMentionDisplayHelper(timelineContext: timelineViewModel.context),
                                                     appSettings: parameters.appSettings,
                                                     analyticsService: parameters.analytics,
                                                     composerDraftService: parameters.composerDraftService)
        composerVM.state.showVoiceMessageButton = false
        composerVM.state.showTextFormattingOption = false
        composerVM.state.availableAttachments = [.camera, .photoLibrary, .file]
        composerViewModel = composerVM
    }
    
    func start() {
        viewModel.actionsPublisher
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .dismiss:
                    actionsSubject.send(.dismiss)
                }
            }
            .store(in: &cancellables)
        
        timelineViewModel.actions
            .sink { [weak self] action in
                guard let self else { return }

                switch action {
                case .displayMediaPreview(let mediaPreviewViewModel):
                    viewModel.displayMediaPreview(mediaPreviewViewModel)
                case .composer(let action):
                    composerViewModel.process(timelineAction: action)
                    
                case .displayCameraPicker:
                    actionsSubject.send(.presentMediaUploadPicker(mode: .init(source: .camera, selectionType: .multiple)))
                case .displayMediaPicker:
                    actionsSubject.send(.presentMediaUploadPicker(mode: .init(source: .photoLibrary, selectionType: .multiple)))
                case .displayMediaUploadPreviewScreen(let mediaURLs):
                    actionsSubject.send(.presentMediaUploadPreviewScreen(mediaURLs: mediaURLs))
                    
                case .displayDocumentPicker:
                    actionsSubject.send(.presentMediaUploadPicker(mode: .init(source: .documents, selectionType: .multiple)))
                    
                case .displayMessageForwarding(let forwardingItem):
                    actionsSubject.send(.presentMessageForwarding(forwardingItem: forwardingItem))
                    
                // Intentionally unhandled actions for Agent screen (1:1 DM with Clap AI):
                // - displayEmojiPicker: No emoji reactions on AI messages
                // - displayReportContent: Cannot report Clap AI
                // - displayLocationPicker/displayLocation: Location sharing disabled
                // - displayPollForm: No poll creation
                // - displaySenderDetails: Single sender (Clap AI)
                // - displayThread/viewInRoomTimeline/displayRoom: No navigation to other contexts
                // - displayResolveSendFailure: Handled internally by timeline
                // - hasScrolled/displayMediaDetails: No UI coordination needed
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        composerViewModel.actions
            .sink { [weak self] action in
                guard let self else { return }
                timelineViewModel.process(composerAction: action)
            }
            .store(in: &cancellables)
        
        composerViewModel.start()
    }
    
    func stop() {
        cancellables.removeAll()
        composerViewModel.stop()
        viewModel.stop()
        DivKitComponentsProvider.shared.resetAllCardState(keepHeightCache: true)
    }
        
    func toPresentable() -> AnyView {
        let composerToolbar = ComposerToolbar(context: composerViewModel.context)
        
        return AnyView(AgentScreen(context: viewModel.context,
                                   timelineContext: timelineViewModel.context,
                                   composerToolbar: composerToolbar))
    }
}
