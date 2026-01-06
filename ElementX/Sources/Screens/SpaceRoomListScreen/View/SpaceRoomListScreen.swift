//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct SpaceRoomListScreen: View {
    @Bindable var context: SpaceRoomListScreenViewModel.Context

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                roomList
            }
        }
        .background(Color.compound.bgCanvasDefault.ignoresSafeArea())
        .toolbarRole(RoomHeaderView.toolbarRole)
        .navigationTitle(context.viewState.spaceName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbar }
        .sheet(item: $context.leaveSpaceViewModel) { leaveSpaceViewModel in
            LeaveSpaceView(context: leaveSpaceViewModel.context)
        }
        .alert(item: $context.removeRoomConfirmation) { confirmation in
            Alert(
                title: Text(L10n.screenSpaceRemoveRoomAlertTitle),
                message: Text(L10n.screenSpaceRemoveRoomAlertMessage(confirmation.roomName)),
                primaryButton: .destructive(Text(L10n.actionRemove)) {
                    context.send(viewAction: .removeRoomFromSpace(roomID: confirmation.id, roomName: confirmation.roomName))
                },
                secondaryButton: .cancel()
            )
        }
    }

    @ViewBuilder
    private var roomList: some View {
        // Joined rooms section
        if context.viewState.hasJoinedRooms {
            sectionHeader(title: L10n.spaceRoomListJoinedSectionTitle)

            ForEach(context.viewState.joinedRooms) { item in
                if case .joined(let info) = item {
                    SpaceRoomJoinedCell(info: info,
                                        isSelected: false,
                                        mediaProvider: context.mediaProvider) {
                        context.send(viewAction: .selectRoom(item))
                    }
                    .contextMenu {
                        joinedRoomContextMenu(for: info)
                    }
                }
            }
        }

        // Unjoined rooms section
        if context.viewState.hasUnjoinedRooms {
            sectionHeader(title: L10n.spaceRoomListUnjoinedSectionTitle)

            ForEach(context.viewState.unjoinedRooms) { item in
                if case .unjoined(let proxy) = item {
                    SpaceRoomUnjoinedCell(spaceRoomProxy: proxy,
                                          isJoining: context.viewState.joiningRoomIDs.contains(proxy.id),
                                          mediaProvider: context.mediaProvider) {
                        context.send(viewAction: .joinRoom(proxy))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.compound.bodySMSemibold)
            .foregroundStyle(.compound.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 8)
    }

    @ViewBuilder
    private func joinedRoomContextMenu(for info: JoinedRoomInfo) -> some View {
        if info.badges.isDotShown {
            Button {
                context.send(viewAction: .markAsRead(roomID: info.id))
            } label: {
                Label(L10n.screenRoomlistMarkAsRead, icon: \.markAsRead)
            }
        } else {
            Button {
                context.send(viewAction: .markAsUnread(roomID: info.id))
            } label: {
                Label(L10n.screenRoomlistMarkAsUnread, icon: \.markAsUnread)
            }
        }

        if info.isFavourite {
            Button {
                context.send(viewAction: .markAsFavourite(roomID: info.id, isFavourite: false))
            } label: {
                Label(L10n.commonFavourited, icon: \.favouriteSolid)
            }
        } else {
            Button {
                context.send(viewAction: .markAsFavourite(roomID: info.id, isFavourite: true))
            } label: {
                Label(L10n.commonFavourite, icon: \.favourite)
            }
        }

        Button {
            context.send(viewAction: .showRoomDetails(roomID: info.id))
        } label: {
            Label(L10n.commonSettings, icon: \.settings)
        }

        Button(role: .destructive) {
            context.send(viewAction: .leaveRoom(roomID: info.id))
        } label: {
            Label(L10n.actionLeaveRoom, icon: \.leave)
        }

        if context.viewState.canManageSpaceChildren {
            Button(role: .destructive) {
                context.send(viewAction: .confirmRemoveRoomFromSpace(roomID: info.id, roomName: info.name))
            } label: {
                Label(L10n.screenSpaceRemoveRoom, icon: \.close)
            }
        }
    }

    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            RoomHeaderView(roomName: context.viewState.spaceName,
                           roomAvatar: context.viewState.spaceAvatar,
                           mediaProvider: context.mediaProvider)
        }

        ToolbarItem(placement: .primaryAction) {
            Menu {
                Section {
                    if context.viewState.roomProxy != nil {
                        Button { context.send(viewAction: .displayMembers) } label: {
                            Label(L10n.screenSpaceMenuActionMembers, icon: \.user)
                        }
                    }
                    if let permalink = context.viewState.permalink {
                        ShareLink(item: permalink) {
                            Label(L10n.actionShare, icon: \.shareIos)
                        }
                    }

                    if context.viewState.isSpaceManagementEnabled,
                       context.viewState.roomProxy != nil {
                        Button { context.send(viewAction: .spaceSettings) } label: {
                            Label(L10n.commonSettings, icon: \.settings)
                        }
                    }
                }

                if context.viewState.canManageSpaceChildren {
                    Section {
                        Button { context.send(viewAction: .createRoom) } label: {
                            Label(L10n.screenSpaceCreateRoom, icon: \.plus)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) { context.send(viewAction: .leaveSpace) } label: {
                        Label(L10n.actionLeaveSpace, icon: \.leave)
                    }
                }
            } label: {
                Image(systemSymbol: .ellipsis)
            }
        }
    }
}

// MARK: - Previews

struct SpaceRoomListScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = makeViewModel()

    static var previews: some View {
        NavigationStack {
            SpaceRoomListScreen(context: viewModel.context)
        }
    }

    static func makeViewModel() -> SpaceRoomListScreenViewModel {
        let spaceRoomProxy = SpaceRoomProxyMock(.init(id: "!space:matrix.org",
                                                      name: "Engineering Team",
                                                      isSpace: true,
                                                      childrenCount: 10,
                                                      joinedMembersCount: 50,
                                                      topic: "Engineering team discussions"))
        let spaceRoomListProxy = SpaceRoomListProxyMock(.init(spaceRoomProxy: spaceRoomProxy,
                                                              initialSpaceRooms: .mockSpaceList))

        let clientProxy = ClientProxyMock(.init())
        let userSession = UserSessionMock(.init(clientProxy: clientProxy))

        return SpaceRoomListScreenViewModel(spaceRoomListProxy: spaceRoomListProxy,
                                            spaceServiceProxy: SpaceServiceProxyMock(.init()),
                                            userSession: userSession,
                                            appSettings: AppSettings(),
                                            userIndicatorController: UserIndicatorControllerMock())
    }
}
