//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct KickMemberConfirmationView: View {
    @Environment(\.dismiss) private var dismiss

    let context: KickMemberConfirmationViewModel.Context

    @State private var scrollViewHeight: CGFloat = .zero
    @State private var buttonsHeight: CGFloat = .zero
    private let topPadding = 19.0

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                toggleRow
            }
            .readHeight($scrollViewHeight)
        }
        .backportSafeAreaBar(edge: .bottom, spacing: 0) {
            buttons
                .readHeight($buttonsHeight)
        }
        .scrollBounceBehavior(.basedOnSize)
        .padding(.top, topPadding)
        .presentationDetents([.height(scrollViewHeight + buttonsHeight + topPadding)])
        .presentationDragIndicator(.visible)
        .presentationBackground(.compound.bgCanvasDefault)
    }

    var header: some View {
        VStack(spacing: 16) {
            BigIcon(icon: \.error, style: .alertSolid)

            VStack(spacing: 8) {
                Text(context.viewState.title)
                    .font(.compound.headingMDBold)
                    .foregroundStyle(.compound.textPrimary)
                    .multilineTextAlignment(.center)

                Text(context.viewState.subtitle)
                    .font(.compound.bodyMD)
                    .foregroundStyle(.compound.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
    }

    var toggleRow: some View {
        Button {
            context.send(viewAction: .toggleRemoveFromAllRooms)
        } label: {
            HStack(spacing: 16) {
                Text(L10n.screenBottomSheetManageRoomMemberRemoveFromAllRooms)
                    .font(.compound.bodyLGSemibold)
                    .foregroundStyle(.compound.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ListRowAccessory.multiSelection(context.viewState.removeFromAllRooms)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    var buttons: some View {
        VStack(spacing: 16) {
            Button(role: .destructive) {
                context.send(viewAction: .confirm)
            } label: {
                Text(context.viewState.confirmButtonTitle)
            }
            .buttonStyle(.compound(.primary))

            Button(L10n.actionCancel, action: dismiss.callAsFunction)
                .buttonStyle(.compound(.tertiary))
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}

// MARK: - Previews

struct KickMemberConfirmationView_Previews: PreviewProvider, TestablePreview {
    static let viewModel = KickMemberConfirmationViewModel(memberID: "@alice:matrix.org",
                                                           memberName: "Alice")

    static var previews: some View {
        KickMemberConfirmationView(context: viewModel.context)
            .previewDisplayName("Default")
    }
}
