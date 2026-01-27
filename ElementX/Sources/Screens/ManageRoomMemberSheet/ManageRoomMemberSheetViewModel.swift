//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation
import SwiftUI

typealias ManageRoomMemberSheetViewModelType = StateStoreViewModelV2<ManageRoomMemberSheetViewState, ManageRoomMemberSheetViewAction>

class ManageRoomMemberSheetViewModel: ManageRoomMemberSheetViewModelType, ManageRoomMemberSheetViewModelProtocol {
    private let roomProxy: JoinedRoomProxyProtocol
    private let clapSpaceAPI: ClapSpaceAPIProtocol
    private let userIndicatorController: UserIndicatorControllerProtocol
    private let analyticsService: AnalyticsService

    private var actionsSubject: PassthroughSubject<ManageRoomMemberSheetViewModelAction, Never> = .init()
    private var kickConfirmationCancellable: AnyCancellable?

    var actions: AnyPublisher<ManageRoomMemberSheetViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(memberDetails: ManageRoomMemberDetails,
         permissions: ManageRoomMemberPermissions,
         roomProxy: JoinedRoomProxyProtocol,
         clapSpaceAPI: ClapSpaceAPIProtocol,
         userIndicatorController: UserIndicatorControllerProtocol,
         analyticsService: AnalyticsService,
         mediaProvider: MediaProviderProtocol) {
        self.userIndicatorController = userIndicatorController
        self.roomProxy = roomProxy
        self.clapSpaceAPI = clapSpaceAPI
        self.analyticsService = analyticsService
        super.init(initialViewState: .init(memberDetails: memberDetails, permissions: permissions), mediaProvider: mediaProvider)
    }

    override func process(viewAction: ManageRoomMemberSheetViewAction) {
        switch viewAction {
        case .kick:
            displayAlert(.kick)
        case .ban:
            displayAlert(.ban)
        case .displayDetails:
            actionsSubject.send(.dismiss(shouldShowDetails: true))
        case .unban:
            displayAlert(.unban)
        }
    }

    private func displayAlert(_ alertType: ManageRoomMemberSheetViewAlertType) {
        let memberID = state.memberDetails.id
        let memberName = state.memberDetails.name
        let isSpace = roomProxy.infoPublisher.value.isSpace

        var reason: String?
        let reasonBinding: Binding<String> = .init(get: { reason ?? "" },
                                                   set: { reason = $0.isBlank ? nil : $0 })

        switch alertType {
        case .kick:
            if isSpace {
                // Space kick: show custom confirmation sheet with toggle
                showKickMemberConfirmation(memberID: memberID, memberName: memberName)
            } else {
                // Room kick: show reason field
                state.bindings.alertInfo = .init(
                    id: alertType,
                    title: L10n.screenBottomSheetManageRoomMemberKickMemberConfirmationTitle,
                    message: L10n.screenBottomSheetManageRoomMemberKickMemberConfirmationDescription,
                    primaryButton: .init(title: L10n.actionCancel, role: .cancel) { },
                    secondaryButton: .init(title: L10n.screenBottomSheetManageRoomMemberKickMemberConfirmationAction) { [weak self] in
                        Task { await self?.kickMember(id: memberID, name: memberName, reason: reason, removeFromAllChildRooms: false) }
                    },
                    textFields: [.init(placeholder: L10n.commonReason,
                                       text: reasonBinding,
                                       autoCapitalization: .sentences,
                                       autoCorrectionDisabled: false)]
                )
            }
        case .ban:
            state.bindings.alertInfo = .init(id: alertType,
                                             title: L10n.screenBottomSheetManageRoomMemberBanMemberConfirmationTitle,
                                             message: isSpace ? L10n.screenBottomSheetManageRoomMemberBanMemberFromSpaceConfirmationDescription : L10n.screenBottomSheetManageRoomMemberBanMemberConfirmationDescription,
                                             primaryButton: .init(title: L10n.actionCancel, role: .cancel) { },
                                             secondaryButton: .init(title: L10n.screenBottomSheetManageRoomMemberBanMemberConfirmationAction) { [weak self] in Task { await self?.banMember(id: memberID, name: memberName, reason: reason) } },
                                             textFields: [.init(placeholder: L10n.commonReason,
                                                                text: reasonBinding,
                                                                autoCapitalization: .sentences,
                                                                autoCorrectionDisabled: false)])
        case .unban:
            state.bindings.alertInfo = .init(id: alertType,
                                             title: L10n.screenBottomSheetManageRoomMemberUnbanMemberConfirmationTitle,
                                             message: L10n.screenBottomSheetManageRoomMemberUnbanMemberConfirmationDescription,
                                             primaryButton: .init(title: L10n.actionCancel, role: .cancel) { },
                                             secondaryButton: .init(title: L10n.screenBottomSheetManageRoomMemberUnbanMemberConfirmationAction) { [weak self] in Task { await self?.unbanMember(id: memberID, name: memberName) } })
        }
    }

    private func kickMember(id: String, name: String?, reason: String?, removeFromAllChildRooms: Bool = false) async {
        let indicatorTitle = L10n.screenBottomSheetManageRoomMemberRemovingUser(name ?? id)
        showManageMemberIndicator(title: indicatorTitle)

        // 1. Kick from space/room using Matrix SDK
        switch await roomProxy.kickUser(id, reason: reason) {
        case .success:
            // 2. If this is a space and user opted to remove from child rooms, call Clap API
            if roomProxy.infoPublisher.value.isSpace, removeFromAllChildRooms {
                let removalResult = await clapSpaceAPI.removeMemberFromAllChildRooms(
                    spaceID: roomProxy.id,
                    userID: id
                )
                switch removalResult {
                case .success(let result):
                    MXLog.info("Removed user from \(result.removed.count) child rooms, \(result.failed.count) skipped")
                case .failure(let error):
                    MXLog.error("Failed to remove from child rooms: \(error)")
                    // Don't show warning - main kick succeeded, child room removal is best-effort
                }
            }
            hideManageMemberIndicator(title: indicatorTitle)
            analyticsService.trackRoomModeration(action: .KickMember, role: nil)
            actionsSubject.send(.dismiss(shouldShowDetails: false))
        case .failure:
            showManageMemberFailure(title: indicatorTitle)
        }
    }

    private func showKickMemberConfirmation(memberID: String, memberName: String?) {
        let viewModel = KickMemberConfirmationViewModel(memberID: memberID, memberName: memberName)
        kickConfirmationCancellable = viewModel.actions
            .sink { [weak self] (action: KickMemberConfirmationViewModelAction) in
                guard let self else { return }
                switch action {
                case .confirm(let removeFromAllRooms):
                    state.bindings.kickMemberConfirmation = nil
                    Task { [weak self] in
                        await self?.kickMember(id: memberID, name: memberName, reason: nil, removeFromAllChildRooms: removeFromAllRooms)
                    }
                case .cancel:
                    state.bindings.kickMemberConfirmation = nil
                }
            }
        state.bindings.kickMemberConfirmation = viewModel
    }

    private func banMember(id: String, name: String?, reason: String?) async {
        let indicatorTitle = L10n.screenBottomSheetManageRoomMemberBanningUser(name ?? id)
        showManageMemberIndicator(title: indicatorTitle)

        switch await roomProxy.banUser(id, reason: reason) {
        case .success:
            hideManageMemberIndicator(title: indicatorTitle)
            analyticsService.trackRoomModeration(action: .BanMember, role: nil)
            actionsSubject.send(.dismiss(shouldShowDetails: false))
        case .failure:
            showManageMemberFailure(title: indicatorTitle)
        }
    }

    private func unbanMember(id: String, name: String?) async {
        let indicatorTitle = L10n.screenBottomSheetManageRoomMemberUnbanningUser(name ?? id)
        showManageMemberIndicator(title: indicatorTitle)

        switch await roomProxy.unbanUser(id) {
        case .success:
            hideManageMemberIndicator(title: indicatorTitle)
            analyticsService.trackRoomModeration(action: .UnbanMember, role: nil)
            actionsSubject.send(.dismiss(shouldShowDetails: false))
        case .failure:
            showManageMemberFailure(title: indicatorTitle)
        }
    }

    private func showManageMemberIndicator(title: String) {
        userIndicatorController.submitIndicator(UserIndicator(id: title,
                                                              type: .toast(progress: .indeterminate),
                                                              title: title,
                                                              persistent: true))
    }

    private func hideManageMemberIndicator(title: String) {
        userIndicatorController.retractIndicatorWithId(title)
    }

    private func showManageMemberFailure(title: String) {
        userIndicatorController.retractIndicatorWithId(title)
        userIndicatorController.submitIndicator(UserIndicator(title: L10n.commonFailed, iconName: "xmark"))
    }
}

extension ManageRoomMemberSheetViewModel: Identifiable {
    var id: String {
        state.memberDetails.id
    }
}
