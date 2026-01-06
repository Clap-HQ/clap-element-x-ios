//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

typealias CreateRoomInSpaceScreenViewModelType = StateStoreViewModelV2<CreateRoomInSpaceScreenViewState, CreateRoomInSpaceScreenViewAction>

class CreateRoomInSpaceScreenViewModel: CreateRoomInSpaceScreenViewModelType, CreateRoomInSpaceScreenViewModelProtocol {
    private let userSession: UserSessionProtocol
    private let mediaUploadingPreprocessor: MediaUploadingPreprocessor
    private let userIndicatorController: UserIndicatorControllerProtocol
    private var avatarImageMedia: MediaInfo?

    private var actionsSubject: PassthroughSubject<CreateRoomInSpaceScreenViewModelAction, Never> = .init()

    var actions: AnyPublisher<CreateRoomInSpaceScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(spaceID: String,
         spaceName: String,
         userSession: UserSessionProtocol,
         userIndicatorController: UserIndicatorControllerProtocol,
         appSettings: AppSettings) {
        self.userSession = userSession
        self.userIndicatorController = userIndicatorController
        mediaUploadingPreprocessor = MediaUploadingPreprocessor(appSettings: appSettings)

        // Default: Visible to space members, encryption enabled
        let bindings = CreateRoomInSpaceScreenViewStateBindings(roomName: "",
                                                                 roomTopic: "",
                                                                 visibility: SpaceRoomVisibility.spaceMembers,
                                                                 isEncrypted: true)

        super.init(initialViewState: CreateRoomInSpaceScreenViewState(spaceID: spaceID,
                                                                       spaceName: spaceName,
                                                                       bindings: bindings),
                   mediaProvider: userSession.mediaProvider)
    }

    // MARK: - Public

    override func process(viewAction: CreateRoomInSpaceScreenViewAction) {
        switch viewAction {
        case .createRoom:
            Task { await createRoom() }
        case .displayCameraPicker:
            actionsSubject.send(.displayCameraPicker)
        case .displayMediaPicker:
            actionsSubject.send(.displayMediaPicker)
        case .removeImage:
            avatarImageMedia = nil
            state.avatarURL = nil
        case .dismiss:
            actionsSubject.send(.dismiss)
        }
    }

    func updateAvatar(fileURL: URL) {
        showLoadingIndicator()
        Task { [weak self] in
            guard let self else { return }
            do {
                guard case let .success(maxUploadSize) = await userSession.clientProxy.maxMediaUploadSize else {
                    MXLog.error("Failed to get max upload size")
                    userIndicatorController.alertInfo = AlertInfo(id: .init())
                    hideLoadingIndicator()
                    return
                }
                let mediaInfo = try await mediaUploadingPreprocessor.processMedia(at: fileURL, maxUploadSize: maxUploadSize).get()

                switch mediaInfo {
                case .image(_, let thumbnailURL, _):
                    avatarImageMedia = mediaInfo
                    state.avatarURL = thumbnailURL
                default:
                    break
                }
            } catch {
                userIndicatorController.alertInfo = AlertInfo(id: .init())
            }
            hideLoadingIndicator()
        }
    }

    // MARK: - Private

    private func createRoom() async {
        state.isCreating = true
        defer {
            state.isCreating = false
            hideLoadingIndicator()
        }
        showLoadingIndicator()

        let avatarURL: URL?
        if let media = avatarImageMedia {
            switch await userSession.clientProxy.uploadMedia(media) {
            case .success(let url):
                avatarURL = URL(string: url)
            case .failure(let error):
                switch error {
                case .failedUploadingMedia(let errorKind):
                    switch errorKind {
                    case .tooLarge:
                        state.bindings.alertInfo = AlertInfo(id: .fileTooLarge)
                    default:
                        state.bindings.alertInfo = AlertInfo(id: .failedUploadingMedia)
                    }
                case .invalidMedia:
                    state.bindings.alertInfo = AlertInfo(id: .mediaFileError)
                default:
                    state.bindings.alertInfo = AlertInfo(id: .unknown)
                }
                return
            }
        } else {
            avatarURL = nil
        }

        let result = await userSession.clientProxy.createRoomInSpace(
            spaceID: state.spaceID,
            name: state.bindings.roomName,
            topic: state.bindings.roomTopic.isBlank ? nil : state.bindings.roomTopic,
            visibility: state.bindings.visibility,
            isEncrypted: state.bindings.isEncrypted,
            avatarURL: avatarURL
        )

        switch result {
        case .success(let roomID):
            actionsSubject.send(.createdRoom(roomID: roomID))
        case .failure:
            state.bindings.alertInfo = AlertInfo(id: .failedCreatingRoom,
                                                 title: L10n.commonError,
                                                 message: L10n.screenStartChatErrorStartingChat)
        }
    }

    // MARK: Loading indicator

    private static let loadingIndicatorIdentifier = "\(CreateRoomInSpaceScreenViewModel.self)-Loading"

    private func showLoadingIndicator() {
        userIndicatorController.submitIndicator(UserIndicator(id: Self.loadingIndicatorIdentifier,
                                                              type: .modal(progress: .indeterminate, interactiveDismissDisabled: true, allowsInteraction: false),
                                                              title: L10n.commonLoading,
                                                              persistent: true))
    }

    private func hideLoadingIndicator() {
        userIndicatorController.retractIndicatorWithId(Self.loadingIndicatorIdentifier)
    }
}
