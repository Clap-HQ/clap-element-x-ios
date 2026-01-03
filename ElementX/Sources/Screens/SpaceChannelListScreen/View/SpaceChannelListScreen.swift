//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct SpaceChannelListScreen: View {
    @Bindable var context: SpaceChannelListScreenViewModel.Context

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                channelList
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
    }

    @ViewBuilder
    private var channelList: some View {
        // Joined channels section
        if context.viewState.hasJoinedChannels {
            sectionHeader(title: L10n.spaceChannelListJoinedSectionTitle)

            ForEach(context.viewState.joinedChannels) { item in
                if case .joined(let info) = item {
                    SpaceChannelJoinedCell(info: info,
                                           isSelected: false,
                                           mediaProvider: context.mediaProvider) {
                        context.send(viewAction: .selectChannel(item))
                    }
                    .contextMenu {
                        joinedChannelContextMenu(for: info)
                    }
                }
            }
        }

        // Unjoined channels section
        if context.viewState.hasUnjoinedChannels {
            sectionHeader(title: L10n.spaceChannelListUnjoinedSectionTitle)

            ForEach(context.viewState.unjoinedChannels) { item in
                if case .unjoined(let proxy) = item {
                    SpaceChannelUnjoinedCell(spaceRoomProxy: proxy,
                                             isJoining: context.viewState.joiningChannelIDs.contains(proxy.id),
                                             mediaProvider: context.mediaProvider) {
                        context.send(viewAction: .joinChannel(proxy))
                    }
                }
            }
        }

        if context.viewState.isPaginating {
            ProgressView()
                .padding()
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
    private func joinedChannelContextMenu(for info: JoinedChannelInfo) -> some View {
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

struct SpaceChannelListScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = makeViewModel()

    static var previews: some View {
        NavigationStack {
            SpaceChannelListScreen(context: viewModel.context)
        }
    }

    static func makeViewModel() -> SpaceChannelListScreenViewModel {
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

        return SpaceChannelListScreenViewModel(spaceRoomListProxy: spaceRoomListProxy,
                                               spaceServiceProxy: SpaceServiceProxyMock(.init()),
                                               userSession: userSession,
                                               appSettings: AppSettings(),
                                               userIndicatorController: UserIndicatorControllerMock())
    }
}
