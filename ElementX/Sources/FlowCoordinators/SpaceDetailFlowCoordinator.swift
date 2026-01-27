//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation

enum SpaceDetailFlowCoordinatorAction {
    case presentCallScreen(roomProxy: JoinedRoomProxyProtocol)
    case sessionVerification(SessionVerificationScreenFlow)
    case continueWithSpaceFlow(SpaceRoomListProxyProtocol)
    case finished
}

/// Entry point for SpaceDetailFlowCoordinator
enum SpaceDetailFlowCoordinatorEntryPoint {
    /// Show space detail screen for an already joined space
    case spaceDetail(SpaceRoomListProxyProtocol)
    /// Show space detail screen after joining (with JoinAllRoomsConfirmation)
    case spaceDetailAfterJoin(SpaceRoomListProxyProtocol)
    /// Show join space screen first, then space detail after joining
    case joinSpace(SpaceRoomProxyProtocol)
}

/// A flow coordinator for SpaceDetailScreen when accessed from the home screen.
/// This handles all SpaceDetailScreen actions including room navigation, members, settings, etc.
/// Also supports joining unjoined spaces via JoinRoomScreen.
class SpaceDetailFlowCoordinator: FlowCoordinatorProtocol {
    private var entryPoint: SpaceDetailFlowCoordinatorEntryPoint
    private let navigationSplitCoordinator: NavigationSplitCoordinator
    private let flowParameters: CommonFlowParameters

    private var userSession: UserSessionProtocol { flowParameters.userSession }

    private let navigationStackCoordinator: NavigationStackCoordinator

    // periphery:ignore - retaining purpose
    private var joinRoomCoordinator: JoinRoomScreenCoordinator?
    // periphery:ignore - retaining purpose
    private var spaceDetailCoordinator: SpaceDetailScreenCoordinator?
    // periphery:ignore - retaining purpose
    private var roomFlowCoordinator: RoomFlowCoordinator?
    // periphery:ignore - retaining purpose
    private var roomDetailsCoordinator: RoomFlowCoordinator?
    // periphery:ignore - retaining purpose
    private var membersFlowCoordinator: RoomMembersFlowCoordinator?
    // periphery:ignore - retaining purpose
    private var spaceSettingsFlowCoordinator: RoomFlowCoordinator?
    // periphery:ignore - retaining purpose
    private var createRoomInSpaceCoordinator: CreateRoomInSpaceScreenCoordinator?
    // periphery:ignore - retaining purpose
    private var createRoomInSpaceNavigationStackCoordinator: NavigationStackCoordinator?

    private var cancellables = Set<AnyCancellable>()

    private let actionsSubject: PassthroughSubject<SpaceDetailFlowCoordinatorAction, Never> = .init()
    var actionsPublisher: AnyPublisher<SpaceDetailFlowCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    /// Callback to refresh home screen space children after room creation/removal
    var refreshHomeScreenSpaceChildren: ((String) async -> Void)?

    init(entryPoint: SpaceDetailFlowCoordinatorEntryPoint,
         navigationSplitCoordinator: NavigationSplitCoordinator,
         flowParameters: CommonFlowParameters) {
        self.entryPoint = entryPoint
        self.navigationSplitCoordinator = navigationSplitCoordinator
        self.flowParameters = flowParameters

        self.navigationStackCoordinator = NavigationStackCoordinator(navigationSplitCoordinator: navigationSplitCoordinator)
    }

    /// Convenience initializer for showing space detail directly (backward compatibility)
    convenience init(spaceRoomListProxy: SpaceRoomListProxyProtocol,
                     navigationSplitCoordinator: NavigationSplitCoordinator,
                     flowParameters: CommonFlowParameters,
                     shouldShowJoinAllRoomsConfirmation: Bool = false) {
        let entryPoint: SpaceDetailFlowCoordinatorEntryPoint = shouldShowJoinAllRoomsConfirmation
            ? .spaceDetailAfterJoin(spaceRoomListProxy)
            : .spaceDetail(spaceRoomListProxy)
        self.init(entryPoint: entryPoint,
                  navigationSplitCoordinator: navigationSplitCoordinator,
                  flowParameters: flowParameters)
    }

    func start(animated: Bool = true) {
        switch entryPoint {
        case .spaceDetail(let spaceRoomListProxy):
            presentSpaceDetailScreen(spaceRoomListProxy: spaceRoomListProxy,
                                     shouldShowJoinAllRoomsConfirmation: false,
                                     animated: animated)
        case .spaceDetailAfterJoin(let spaceRoomListProxy):
            presentSpaceDetailScreen(spaceRoomListProxy: spaceRoomListProxy,
                                     shouldShowJoinAllRoomsConfirmation: true,
                                     animated: animated)
        case .joinSpace(let spaceRoomProxy):
            presentJoinSpaceScreen(spaceRoomProxy: spaceRoomProxy, animated: animated)
        }
    }

    func handleAppRoute(_ appRoute: AppRoute, animated: Bool) {
        // Currently no routes to handle
    }

    func clearRoute(animated: Bool) {
        dismiss(animated: animated)
    }

    // MARK: - Join Space

    private func presentJoinSpaceScreen(spaceRoomProxy: SpaceRoomProxyProtocol, animated: Bool) {
        let parameters = JoinRoomScreenCoordinatorParameters(source: .space(spaceRoomProxy),
                                                             userSession: userSession,
                                                             userIndicatorController: flowParameters.userIndicatorController,
                                                             appSettings: flowParameters.appSettings)
        let coordinator = JoinRoomScreenCoordinator(parameters: parameters)
        joinRoomCoordinator = coordinator

        coordinator.actionsPublisher
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .joined(.space(let spaceRoomListProxy)):
                    // Space 초대 수락 후 SpaceDetailScreen으로 전환
                    joinRoomCoordinator = nil
                    entryPoint = .spaceDetailAfterJoin(spaceRoomListProxy)
                    // JoinRoomScreen을 SpaceDetailScreen으로 교체
                    presentSpaceDetailScreen(spaceRoomListProxy: spaceRoomListProxy,
                                             shouldShowJoinAllRoomsConfirmation: true,
                                             animated: true,
                                             replaceRoot: true)
                case .joined(.roomID):
                    MXLog.error("Expected to join a space, but got a room ID instead.")
                    dismiss(animated: true)
                case .cancelled:
                    dismiss(animated: true)
                case .presentDeclineAndBlock:
                    MXLog.error("Joining a space shouldn't involve an inviter.")
                    dismiss(animated: true)
                }
            }
            .store(in: &cancellables)

        coordinator.start()
        navigationStackCoordinator.setRootCoordinator(coordinator)
        navigationSplitCoordinator.setDetailCoordinator(navigationStackCoordinator, animated: animated)
    }

    // MARK: - Space Detail

    private func presentSpaceDetailScreen(spaceRoomListProxy: SpaceRoomListProxyProtocol,
                                          shouldShowJoinAllRoomsConfirmation: Bool,
                                          animated: Bool,
                                          replaceRoot: Bool = false) {
        let coordinator = SpaceDetailScreenCoordinator(parameters: .init(spaceRoomListProxy: spaceRoomListProxy,
                                                                         spaceServiceProxy: userSession.clientProxy.spaceService,
                                                                         userSession: userSession,
                                                                         appSettings: flowParameters.appSettings,
                                                                         userIndicatorController: flowParameters.userIndicatorController),
                                                       shouldShowJoinAllRoomsConfirmation: shouldShowJoinAllRoomsConfirmation)
        spaceDetailCoordinator = coordinator

        coordinator.actionsPublisher
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .selectRoom(let roomID):
                    presentRoom(roomID: roomID, animated: true)
                case .showRoomDetails(let roomID):
                    presentRoomDetails(roomID: roomID, animated: true)
                case .dismiss:
                    dismiss(animated: true)
                case .displayMembers(let roomProxy):
                    presentMembers(roomProxy: roomProxy, animated: true)
                case .inviteUsers(let roomProxy):
                    presentInviteUsers(roomProxy: roomProxy, animated: true)
                case .displaySpaceSettings(let roomProxy):
                    presentSpaceSettings(roomProxy: roomProxy, animated: true)
                case .presentCreateRoomInSpace(let spaceID, let spaceName):
                    presentCreateRoomInSpace(spaceID: spaceID, spaceName: spaceName, animated: true)
                case .removedRoomFromSpace(let spaceID):
                    Task { [weak self] in
                        await self?.refreshHomeScreenSpaceChildren?(spaceID)
                    }
                case .leftSpace:
                    dismiss(animated: true)
                }
            }
            .store(in: &cancellables)

        coordinator.start()

        if replaceRoot {
            // JoinRoomScreen → SpaceDetailScreen 교체
            navigationStackCoordinator.setRootCoordinator(coordinator, animated: animated)
        } else {
            navigationStackCoordinator.setRootCoordinator(coordinator)
            navigationSplitCoordinator.setDetailCoordinator(navigationStackCoordinator, animated: animated)
        }
    }

    private func dismiss(animated: Bool) {
        cancellables.removeAll()
        navigationSplitCoordinator.setDetailCoordinator(nil, animated: animated)
        joinRoomCoordinator = nil
        spaceDetailCoordinator = nil
        roomFlowCoordinator = nil
        roomDetailsCoordinator = nil
        membersFlowCoordinator = nil
        spaceSettingsFlowCoordinator = nil
        createRoomInSpaceCoordinator = nil
        createRoomInSpaceNavigationStackCoordinator = nil
        actionsSubject.send(.finished)
    }

    // MARK: - Room Flow

    private func presentRoom(roomID: String, animated: Bool) {
        guard roomFlowCoordinator == nil else {
            MXLog.warning("Room flow coordinator already exists, ignoring duplicate presentation request")
            return
        }

        let coordinator = RoomFlowCoordinator(roomID: roomID,
                                              isChildFlow: true,
                                              navigationStackCoordinator: navigationStackCoordinator,
                                              flowParameters: flowParameters)

        coordinator.actions
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .presentCallScreen(let roomProxy):
                    actionsSubject.send(.presentCallScreen(roomProxy: roomProxy))
                case .verifyUser(let userID):
                    actionsSubject.send(.sessionVerification(.userInitiator(userID: userID)))
                case .continueWithSpaceFlow(let spaceRoomListProxy),
                     .continueWithSpaceDetailFlow(let spaceRoomListProxy):
                    actionsSubject.send(.continueWithSpaceFlow(spaceRoomListProxy))
                case .finished:
                    roomFlowCoordinator = nil
                }
            }
            .store(in: &cancellables)

        roomFlowCoordinator = coordinator
        coordinator.handleAppRoute(.room(roomID: roomID, via: []), animated: animated)
    }

    private func presentRoomDetails(roomID: String, animated: Bool) {
        guard roomDetailsCoordinator == nil else {
            MXLog.warning("Room details coordinator already exists, ignoring duplicate presentation request")
            return
        }

        let coordinator = RoomFlowCoordinator(roomID: roomID,
                                              isChildFlow: true,
                                              navigationStackCoordinator: navigationStackCoordinator,
                                              flowParameters: flowParameters)
        roomDetailsCoordinator = coordinator

        coordinator.actions
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .presentCallScreen(let roomProxy):
                    actionsSubject.send(.presentCallScreen(roomProxy: roomProxy))
                case .verifyUser(let userID):
                    actionsSubject.send(.sessionVerification(.userInitiator(userID: userID)))
                case .continueWithSpaceFlow, .continueWithSpaceDetailFlow:
                    break // Not applicable for room details
                case .finished:
                    roomDetailsCoordinator = nil
                }
            }
            .store(in: &cancellables)

        coordinator.handleAppRoute(.roomDetails(roomID: roomID), animated: animated)
    }

    // MARK: - Members Flow

    private func presentMembers(roomProxy: JoinedRoomProxyProtocol, animated: Bool) {
        guard membersFlowCoordinator == nil else {
            MXLog.warning("Members flow coordinator already exists, ignoring duplicate presentation request")
            return
        }

        let coordinator = RoomMembersFlowCoordinator(entryPoint: .roomMembersList,
                                                      roomProxy: roomProxy,
                                                      navigationStackCoordinator: navigationStackCoordinator,
                                                      flowParameters: flowParameters)
        membersFlowCoordinator = coordinator

        coordinator.actions
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .finished:
                    membersFlowCoordinator = nil
                case .presentCallScreen(let roomProxy):
                    actionsSubject.send(.presentCallScreen(roomProxy: roomProxy))
                case .verifyUser(let userID):
                    actionsSubject.send(.sessionVerification(.userInitiator(userID: userID)))
                }
            }
            .store(in: &cancellables)

        coordinator.start(animated: animated)
    }

    private func presentInviteUsers(roomProxy: JoinedRoomProxyProtocol, animated: Bool) {
        guard membersFlowCoordinator == nil else {
            MXLog.warning("Members flow coordinator already exists, ignoring duplicate presentation request")
            return
        }

        let coordinator = RoomMembersFlowCoordinator(entryPoint: .inviteUsers,
                                                      roomProxy: roomProxy,
                                                      navigationStackCoordinator: navigationStackCoordinator,
                                                      flowParameters: flowParameters)
        membersFlowCoordinator = coordinator

        coordinator.actions
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .finished:
                    membersFlowCoordinator = nil
                case .presentCallScreen(let roomProxy):
                    actionsSubject.send(.presentCallScreen(roomProxy: roomProxy))
                case .verifyUser(let userID):
                    actionsSubject.send(.sessionVerification(.userInitiator(userID: userID)))
                }
            }
            .store(in: &cancellables)

        coordinator.start(animated: animated)
    }

    // MARK: - Space Settings Flow

    private func presentSpaceSettings(roomProxy: JoinedRoomProxyProtocol, animated: Bool) {
        guard spaceSettingsFlowCoordinator == nil else {
            MXLog.warning("Space settings flow coordinator already exists, ignoring duplicate presentation request")
            return
        }

        let coordinator = RoomFlowCoordinator(roomID: roomProxy.id,
                                              isChildFlow: true,
                                              navigationStackCoordinator: navigationStackCoordinator,
                                              flowParameters: flowParameters)
        spaceSettingsFlowCoordinator = coordinator

        coordinator.actions
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .presentCallScreen(let roomProxy):
                    actionsSubject.send(.presentCallScreen(roomProxy: roomProxy))
                case .verifyUser(let userID):
                    actionsSubject.send(.sessionVerification(.userInitiator(userID: userID)))
                case .continueWithSpaceFlow, .continueWithSpaceDetailFlow:
                    break // Not applicable for space settings
                case .finished:
                    spaceSettingsFlowCoordinator = nil
                }
            }
            .store(in: &cancellables)

        coordinator.handleAppRoute(.roomDetails(roomID: roomProxy.id), animated: animated)
    }

    // MARK: - Create Room in Space

    private func presentCreateRoomInSpace(spaceID: String, spaceName: String, animated: Bool) {
        guard createRoomInSpaceCoordinator == nil else {
            MXLog.warning("Create room in space coordinator already exists, ignoring duplicate presentation request")
            return
        }

        let sheetNavigationStackCoordinator = NavigationStackCoordinator()
        createRoomInSpaceNavigationStackCoordinator = sheetNavigationStackCoordinator

        let coordinator = CreateRoomInSpaceScreenCoordinator(parameters: .init(spaceID: spaceID,
                                                                                spaceName: spaceName,
                                                                                userSession: userSession,
                                                                                userIndicatorController: flowParameters.userIndicatorController,
                                                                                appSettings: flowParameters.appSettings))
        createRoomInSpaceCoordinator = coordinator

        coordinator.actions
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .createdRoom(let roomID):
                    navigationSplitCoordinator.setSheetCoordinator(nil)
                    createRoomInSpaceCoordinator = nil
                    createRoomInSpaceNavigationStackCoordinator = nil
                    // Refresh space children
                    Task { [weak self] in
                        await self?.spaceDetailCoordinator?.refreshSpaceChildren()
                        await self?.refreshHomeScreenSpaceChildren?(spaceID)
                    }
                    // Navigate to the newly created room
                    presentRoom(roomID: roomID, animated: true)
                case .dismiss:
                    navigationSplitCoordinator.setSheetCoordinator(nil)
                    createRoomInSpaceCoordinator = nil
                    createRoomInSpaceNavigationStackCoordinator = nil
                case .displayMediaPickerWithMode(let mode):
                    presentMediaPicker(mode: mode, coordinator: coordinator)
                }
            }
            .store(in: &cancellables)

        coordinator.start()
        sheetNavigationStackCoordinator.setRootCoordinator(coordinator)
        navigationSplitCoordinator.setSheetCoordinator(sheetNavigationStackCoordinator, animated: animated) { [weak self] in
            self?.createRoomInSpaceCoordinator = nil
            self?.createRoomInSpaceNavigationStackCoordinator = nil
        }
    }

    private func presentMediaPicker(mode: MediaPickerScreenMode, coordinator: CreateRoomInSpaceScreenCoordinator) {
        guard let navStackCoordinator = createRoomInSpaceNavigationStackCoordinator else { return }

        let mediaPickerCoordinator = MediaPickerScreenCoordinator(mode: mode,
                                                                   userIndicatorController: flowParameters.userIndicatorController,
                                                                   orientationManager: flowParameters.windowManager) { [weak navStackCoordinator, weak coordinator] action in
            switch action {
            case .selectedMediaAtURLs(let urls):
                if let url = urls.first {
                    coordinator?.updateAvatar(fileURL: url)
                }
                navStackCoordinator?.setSheetCoordinator(nil)
            case .cancel:
                navStackCoordinator?.setSheetCoordinator(nil)
            }
        }
        navStackCoordinator.setSheetCoordinator(mediaPickerCoordinator)
    }
}
