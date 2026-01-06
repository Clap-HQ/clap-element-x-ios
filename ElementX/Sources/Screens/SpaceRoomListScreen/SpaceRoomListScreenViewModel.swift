//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import MatrixRustSDK
import SwiftUI

typealias SpaceRoomListScreenViewModelType = StateStoreViewModelV2<SpaceRoomListScreenViewState, SpaceRoomListScreenViewAction>

class SpaceRoomListScreenViewModel: SpaceRoomListScreenViewModelType, SpaceRoomListScreenViewModelProtocol {
    private var spaceRoomListProxy: SpaceRoomListProxyProtocol
    private let spaceServiceProxy: SpaceServiceProxyProtocol
    private let clientProxy: ClientProxyProtocol
    private let mediaProvider: MediaProviderProtocol
    private let userIndicatorController: UserIndicatorControllerProtocol
    private let appSettings: AppSettings

    private var spaceRoomListCancellables = Set<AnyCancellable>()

    private let actionsSubject: PassthroughSubject<SpaceRoomListScreenViewModelAction, Never> = .init()
    var actionsPublisher: AnyPublisher<SpaceRoomListScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(spaceRoomListProxy: SpaceRoomListProxyProtocol,
         spaceServiceProxy: SpaceServiceProxyProtocol,
         userSession: UserSessionProtocol,
         appSettings: AppSettings,
         userIndicatorController: UserIndicatorControllerProtocol) {
        self.spaceRoomListProxy = spaceRoomListProxy
        self.spaceServiceProxy = spaceServiceProxy
        self.clientProxy = userSession.clientProxy
        self.mediaProvider = userSession.mediaProvider
        self.appSettings = appSettings
        self.userIndicatorController = userIndicatorController

        let spaceProxy = spaceRoomListProxy.spaceRoomProxyPublisher.value

        super.init(initialViewState: SpaceRoomListScreenViewState(
            spaceID: spaceRoomListProxy.id,
            spaceName: spaceProxy.name,
            spaceAvatarURL: spaceProxy.avatarURL,
            spaceMemberCount: spaceProxy.joinedMembersCount,
            spaceTopic: spaceProxy.topic
        ), mediaProvider: userSession.mediaProvider)

        // Populate the list immediately with current data
        let initialSpaceRooms = spaceRoomListProxy.spaceRoomsPublisher.value
        let roomSummaries = clientProxy.roomSummaryProvider.roomListPublisher.value
        updateRoomList(with: initialSpaceRooms, roomSummaries: roomSummaries)

        setupSubscriptions()
        setupSpaceRoomProxy()
    }

    // MARK: - Public

    override func process(viewAction: SpaceRoomListScreenViewAction) {
        switch viewAction {
        case .selectRoom(let item):
            switch item {
            case .joined(let info):
                actionsSubject.send(.selectRoom(roomID: info.id))
            case .unjoined(let proxy):
                Task { await joinRoom(proxy) }
            }
        case .joinRoom(let proxy):
            Task { await joinRoom(proxy) }
        case .showRoomDetails(let roomID):
            actionsSubject.send(.showRoomDetails(roomID: roomID))
        case .markAsRead(let roomID):
            Task { await markAsRead(roomID: roomID) }
        case .markAsUnread(let roomID):
            Task { await markAsUnread(roomID: roomID) }
        case .markAsFavourite(let roomID, let isFavourite):
            Task { await markAsFavourite(roomID: roomID, isFavourite: isFavourite) }
        case .leaveRoom(let roomID):
            Task { await leaveRoom(roomID: roomID) }
        case .confirmRemoveRoomFromSpace(let roomID, let roomName):
            state.bindings.removeRoomConfirmation = RemoveRoomConfirmation(id: roomID, roomName: roomName)
        case .removeRoomFromSpace(let roomID, let roomName):
            state.bindings.removeRoomConfirmation = nil
            Task { await removeRoomFromSpace(roomID: roomID, roomName: roomName) }
        case .displayMembers:
            guard let roomProxy = state.roomProxy else { return }
            actionsSubject.send(.displayMembers(roomProxy: roomProxy))
        case .spaceSettings:
            guard let roomProxy = state.roomProxy else { return }
            actionsSubject.send(.displaySpaceSettings(roomProxy: roomProxy))
        case .createRoom:
            actionsSubject.send(.presentCreateRoomInSpace(spaceID: state.spaceID, spaceName: state.spaceName))
        case .leaveSpace:
            Task { await showLeaveSpaceConfirmation() }
        }
    }

    // MARK: - Private

    private func setupSubscriptions() {
        setupSpaceRoomListSubscriptions()
    }

    private func setupSpaceRoomListSubscriptions() {
        // Clear previous subscriptions when replacing proxy
        spaceRoomListCancellables.removeAll()

        spaceRoomListProxy.spaceRoomProxyPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] spaceProxy in
                guard let self else { return }
                state.spaceName = spaceProxy.name
                state.spaceAvatarURL = spaceProxy.avatarURL
                state.spaceMemberCount = spaceProxy.joinedMembersCount
                state.spaceTopic = spaceProxy.topic
            }
            .store(in: &spaceRoomListCancellables)

        // Combine space rooms and room summaries to update room list atomically
        // This prevents flickering caused by multiple separate updates
        spaceRoomListProxy.spaceRoomsPublisher
            .combineLatest(clientProxy.roomSummaryProvider.roomListPublisher)
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink { [weak self] spaceRooms, roomSummaries in
                guard let self else { return }
                updateRoomList(with: spaceRooms, roomSummaries: roomSummaries)
            }
            .store(in: &spaceRoomListCancellables)

        spaceRoomListProxy.paginationStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] paginationState in
                guard let self else { return }
                if case .idle(let endReached) = paginationState, !endReached {
                    Task { await self.spaceRoomListProxy.paginate() }
                }
            }
            .store(in: &spaceRoomListCancellables)
    }

    private func updateRoomList(with spaceRooms: [SpaceRoomProxyProtocol], roomSummaries: [RoomSummary]) {
        // Build a lookup dictionary for quick access
        let summaryByID = Dictionary(uniqueKeysWithValues: roomSummaries.map { ($0.id, $0) })

        var joinedItems: [SpaceRoomListItem] = []
        var unjoinedItems: [SpaceRoomListItem] = []

        for spaceRoom in spaceRooms {
            // Skip spaces - only show rooms
            guard !spaceRoom.isSpace else { continue }

            if spaceRoom.state == .joined {
                // Get room summary for joined rooms to show last message
                if let summary = summaryByID[spaceRoom.id] {
                    let joinedInfo = JoinedRoomInfo(summary: summary)
                    joinedItems.append(.joined(joinedInfo))
                } else {
                    // Fallback if summary not available
                    let joinedInfo = JoinedRoomInfo(
                        id: spaceRoom.id,
                        name: spaceRoom.name,
                        avatar: spaceRoom.avatar,
                        memberCount: spaceRoom.joinedMembersCount,
                        lastMessage: nil,
                        timestamp: nil,
                        lastMessageDate: nil,
                        isDirect: spaceRoom.isDirect ?? false,
                        badges: .init(isDotShown: false, isMentionShown: false, isMuteShown: false, isCallShown: false),
                        isHighlighted: false,
                        isFavourite: false
                    )
                    joinedItems.append(.joined(joinedInfo))
                }
            } else {
                unjoinedItems.append(.unjoined(spaceRoom))
            }
        }

        // Sort joined rooms by last message date (most recent first)
        let sortedJoinedItems = joinedItems.sorted { lhs, rhs in
            guard case .joined(let lhsInfo) = lhs, case .joined(let rhsInfo) = rhs else { return false }
            let lhsDate = lhsInfo.lastMessageDate ?? .distantPast
            let rhsDate = rhsInfo.lastMessageDate ?? .distantPast
            return lhsDate > rhsDate
        }

        state.joinedRooms = sortedJoinedItems
        state.unjoinedRooms = unjoinedItems
    }

    private func joinRoom(_ spaceRoom: SpaceRoomProxyProtocol) async {
        state.joiningRoomIDs.insert(spaceRoom.id)
        defer { state.joiningRoomIDs.remove(spaceRoom.id) }

        guard case .success = await clientProxy.joinRoom(spaceRoom.id, via: spaceRoom.via) else {
            showFailureIndicator()
            return
        }

        // After joining, the room will appear in the list as joined
    }

    private func markAsRead(roomID: String) async {
        guard case .joined(let roomProxy) = await clientProxy.roomForIdentifier(roomID) else {
            showFailureIndicator()
            return
        }

        // First clear the unread flag, then send read receipt
        guard case .success = await roomProxy.flagAsUnread(false) else {
            showFailureIndicator()
            return
        }

        let receiptType: ReceiptType = appSettings.sharePresence ? .read : .readPrivate
        if case .failure = await roomProxy.markAsRead(receiptType: receiptType) {
            showFailureIndicator()
        }
    }

    private func markAsUnread(roomID: String) async {
        guard case .joined(let roomProxy) = await clientProxy.roomForIdentifier(roomID) else {
            showFailureIndicator()
            return
        }

        guard case .success = await roomProxy.flagAsUnread(true) else {
            showFailureIndicator()
            return
        }
    }

    private func markAsFavourite(roomID: String, isFavourite: Bool) async {
        guard case .joined(let roomProxy) = await clientProxy.roomForIdentifier(roomID) else {
            showFailureIndicator()
            return
        }

        guard case .success = await roomProxy.flagAsFavourite(isFavourite) else {
            showFailureIndicator()
            return
        }
    }

    private func leaveRoom(roomID: String) async {
        guard case .joined(let roomProxy) = await clientProxy.roomForIdentifier(roomID) else {
            showFailureIndicator()
            return
        }

        guard case .success = await roomProxy.leaveRoom() else {
            showFailureIndicator()
            return
        }
    }

    private func removeRoomFromSpace(roomID: String, roomName: String) async {
        showLoadingIndicator()
        defer { hideLoadingIndicator() }

        let spaceID = state.spaceID
        let result = await clientProxy.spaceChildService.removeChildFromSpace(spaceID: spaceID,
                                                                               childRoomID: roomID)
        switch result {
        case .success:
            // Refresh the space room list to reflect the removal
            await refreshSpaceRoomList()
            // Notify coordinator to refresh home screen as well
            actionsSubject.send(.removedRoomFromSpace(spaceID: spaceID))
            userIndicatorController.submitIndicator(UserIndicator(id: "\(Self.self)-RemovedFromSpace",
                                                                  type: .toast,
                                                                  title: L10n.screenSpaceRemoveRoomSuccess(roomName),
                                                                  iconName: "checkmark"))
        case .failure(let error):
            MXLog.error("Failed to remove room \(roomID) from space \(spaceID): \(error)")
            showFailureIndicator()
        }
    }

    func refreshSpaceRoomList() async {
        // Give SDK time to process the state event change
        try? await Task.sleep(for: .milliseconds(500))

        // Fetch a fresh space room list from the service and replace the current proxy
        let result = await spaceServiceProxy.spaceRoomList(spaceID: state.spaceID)
        switch result {
        case .success(let newSpaceRoomList):
            // Paginate to ensure we have all the data
            await newSpaceRoomList.paginate()

            // Wait a bit for pagination results to be available
            try? await Task.sleep(for: .milliseconds(200))

            // Replace the proxy and re-subscribe
            await MainActor.run {
                spaceRoomListProxy = newSpaceRoomList
                setupSpaceRoomListSubscriptions()

                // Immediately update the room list with fresh data
                let spaceRooms = newSpaceRoomList.spaceRoomsPublisher.value
                let roomSummaries = clientProxy.roomSummaryProvider.roomListPublisher.value
                updateRoomList(with: spaceRooms, roomSummaries: roomSummaries)
                MXLog.info("Refreshed space room list for \(state.spaceID) with \(spaceRooms.count) rooms")
            }
        case .failure(let error):
            MXLog.error("Failed to refresh space room list: \(error)")
        }
    }

    private func setupSpaceRoomProxy() {
        Task {
            if case let .joined(roomProxy) = await clientProxy.roomForIdentifier(spaceRoomListProxy.id) {
                await roomProxy.subscribeForUpdates()
                state.roomProxy = roomProxy
                if case let .success(permalinkURL) = await roomProxy.matrixToPermalink() {
                    state.permalink = permalinkURL
                }

                appSettings.$spaceSettingsEnabled
                    .combineLatest(roomProxy.infoPublisher)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] isEnabled, roomInfo in
                        guard let self else { return }
                        // canManageSpaceChildren is always based on power levels, independent of spaceSettingsEnabled
                        if let powerLevels = roomInfo.powerLevels {
                            state.canManageSpaceChildren = powerLevels.canOwnUser(sendStateEvent: .spaceChild)
                        } else {
                            state.canManageSpaceChildren = false
                        }

                        // canEditBaseInfo and canEditRolesAndPermissions require spaceSettingsEnabled
                        guard isEnabled, let powerLevels = roomInfo.powerLevels else {
                            state.canEditBaseInfo = false
                            state.canEditRolesAndPermissions = false
                            return
                        }
                        state.canEditBaseInfo = powerLevels.canOwnUserEditBaseInfo()
                        state.canEditRolesAndPermissions = powerLevels.canOwnUserEditRolesAndPermissions()
                    }
                    .store(in: &cancellables)
            }
        }
    }

    private func showLeaveSpaceConfirmation() async {
        guard case let .success(leaveHandle) = await spaceServiceProxy.leaveSpace(spaceID: spaceRoomListProxy.id) else {
            showFailureIndicator()
            return
        }

        let leaveSpaceViewModel = LeaveSpaceViewModel(spaceName: state.spaceName,
                                                      canEditRolesAndPermissions: appSettings.spaceSettingsEnabled && state.canEditRolesAndPermissions,
                                                      leaveHandle: leaveHandle,
                                                      userIndicatorController: userIndicatorController,
                                                      mediaProvider: mediaProvider)
        leaveSpaceViewModel.actions.sink { [weak self] action in
            guard let self else { return }
            switch action {
            case .didCancel:
                state.bindings.leaveSpaceViewModel = nil
            case .presentRolesAndPermissions:
                // Not supported in space room list context
                state.bindings.leaveSpaceViewModel = nil
            case .didLeaveSpace:
                state.bindings.leaveSpaceViewModel = nil
                actionsSubject.send(.leftSpace)
            }
        }
        .store(in: &cancellables)

        state.bindings.leaveSpaceViewModel = leaveSpaceViewModel
    }

    private func showFailureIndicator() {
        userIndicatorController.submitIndicator(UserIndicator(id: "\(Self.self)-Failure",
                                                              type: .toast,
                                                              title: L10n.errorUnknown,
                                                              iconName: "xmark"))
    }

    // MARK: Loading indicator

    private static let loadingIndicatorIdentifier = "\(SpaceRoomListScreenViewModel.self)-Loading"

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
