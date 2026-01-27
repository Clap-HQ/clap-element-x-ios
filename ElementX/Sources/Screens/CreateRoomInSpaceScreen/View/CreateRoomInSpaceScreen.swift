//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct CreateRoomInSpaceScreen: View {
    @Bindable var context: CreateRoomInSpaceScreenViewModel.Context
    @FocusState private var focus: Focus?

    private enum Focus {
        case name
        case topic
    }

    var body: some View {
        NavigationStack {
            Form {
                roomSection
                topicSection
                visibilitySection
                if context.viewState.showEncryptionToggle {
                    encryptionSection
                }
            }
            .compoundList()
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(L10n.screenSpaceCreateRoom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
            .alert(item: $context.alertInfo)
        }
    }

    private var roomSection: some View {
        Section {
            HStack(alignment: .center, spacing: 16) {
                roomAvatarButton

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.screenRoomDetailsRoomNameLabel.uppercased())
                        .padding(.leading, ListRowPadding.horizontal)
                        .compoundListSectionHeader()

                    TextField(L10n.screenRoomDetailsRoomNameLabel,
                              text: $context.roomName,
                              prompt: Text(L10n.commonRoomNamePlaceholder).foregroundColor(.compound.textSecondary),
                              axis: .horizontal)
                        .font(.compound.bodyLG)
                        .foregroundStyle(.compound.textPrimary)
                        .tint(.compound.iconAccentTertiary)
                        .focused($focus, equals: .name)
                        .padding(.horizontal, ListRowPadding.horizontal)
                        .padding(.vertical, ListRowPadding.vertical)
                        .background(.compound.bgCanvasDefaultLevel1, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .listRowInsets(.init())
            .listRowBackground(Color.clear)
        }
    }

    private var roomAvatarButton: some View {
        Button {
            focus = nil
            context.showAttachmentConfirmationDialog = true
        } label: {
            if let url = context.viewState.avatarURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .scaledFrame(size: 70)
                .clipShape(Circle())
            } else {
                CompoundIcon(\.takePhoto, size: .custom(36), relativeTo: .title)
                    .foregroundColor(.compound.iconSecondary)
                    .scaledFrame(size: 70, relativeTo: .title)
                    .background(.compound.bgSubtlePrimary, in: Circle())
            }
        }
        .buttonStyle(.plain)
        .confirmationDialog("", isPresented: $context.showAttachmentConfirmationDialog) {
            Button(L10n.actionTakePhoto) {
                context.send(viewAction: .displayCameraPicker)
            }
            Button(L10n.actionChoosePhoto) {
                context.send(viewAction: .displayMediaPicker)
            }

            if context.viewState.avatarURL != nil {
                Button(L10n.actionRemove, role: .destructive) {
                    context.send(viewAction: .removeImage)
                }
            }
        }
    }

    private var topicSection: some View {
        Section {
            ListRow(label: .plain(title: L10n.commonTopicPlaceholder),
                    kind: .textField(text: $context.roomTopic, axis: .vertical))
                .lineLimit(3, reservesSpace: false)
                .focused($focus, equals: .topic)
        } header: {
            Text(L10n.screenCreateRoomTopicLabel)
                .compoundListSectionHeader()
        }
    }

    private var visibilitySection: some View {
        Section {
            ForEach(SpaceRoomVisibility.allCases) { visibility in
                ListRow(label: .default(title: visibility.title,
                                        icon: visibility.icon),
                        kind: .selection(isSelected: context.visibility == visibility) {
                            context.visibility = visibility
                        })
            }
        } header: {
            Text(L10n.screenSpaceCreateRoomVisibilityHeader)
                .compoundListSectionHeader()
        } footer: {
            Text(context.viewState.visibilityDescription)
                .compoundListSectionFooter()
        }
    }

    private var encryptionSection: some View {
        Section {
            ListRow(label: .default(title: L10n.screenSpaceCreateRoomEncryptionTitle,
                                    icon: \.lockSolid),
                    kind: .toggle($context.isEncrypted))
        } footer: {
            Text(L10n.screenSpaceCreateRoomEncryptionDescription)
                .compoundListSectionFooter()
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(L10n.actionCancel) {
                context.send(viewAction: .dismiss)
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button(L10n.actionCreate) {
                focus = nil
                context.send(viewAction: .createRoom)
            }
            .disabled(!context.viewState.canCreateRoom)
        }
    }
}

// MARK: - Previews

struct CreateRoomInSpaceScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = {
        let userSession = UserSessionMock(.init(clientProxy: ClientProxyMock(.init(userID: "@userid:example.com"))))
        return CreateRoomInSpaceScreenViewModel(spaceID: "!space:example.com",
                                                 spaceName: "Engineering Team",
                                                 userSession: userSession,
                                                 userIndicatorController: UserIndicatorControllerMock(),
                                                 appSettings: ServiceLocator.shared.settings)
    }()

    static var previews: some View {
        CreateRoomInSpaceScreen(context: viewModel.context)
            .previewDisplayName("Create Room in Space")
    }
}
