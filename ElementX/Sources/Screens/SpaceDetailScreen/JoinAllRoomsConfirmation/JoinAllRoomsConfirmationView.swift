//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct JoinAllRoomsConfirmationView: View {
    @Environment(\.dismiss) private var dismiss

    let context: JoinAllRoomsConfirmationViewModel.Context

    @State private var scrollViewHeight: CGFloat = .zero
    @State private var buttonsHeight: CGFloat = .zero
    private let topPadding = 19.0

    var body: some View {
        ScrollView {
            header
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
            BigIcon(icon: \.takePhoto, style: .successSolid)

            VStack(spacing: 8) {
                Text(L10n.screenJoinAllRoomsConfirmationTitle)
                    .font(.compound.headingMDBold)
                    .foregroundStyle(.compound.textPrimary)
                    .multilineTextAlignment(.center)

                Text(L10n.screenJoinAllRoomsConfirmationSubtitle(context.viewState.spaceName))
                    .font(.compound.bodyMD)
                    .foregroundStyle(.compound.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
    }

    var buttons: some View {
        VStack(spacing: 16) {
            Button {
                context.send(viewAction: .confirm)
            } label: {
                Text(L10n.screenJoinAllRoomsConfirmationAction)
            }
            .buttonStyle(.compound(.primary))

            Button(L10n.actionSkip) {
                context.send(viewAction: .cancel)
            }
            .buttonStyle(.compound(.tertiary))
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}

// MARK: - Previews

struct JoinAllRoomsConfirmationView_Previews: PreviewProvider, TestablePreview {
    static let viewModel = JoinAllRoomsConfirmationViewModel(spaceID: "!space:matrix.org",
                                                              spaceName: "My Space")

    static var previews: some View {
        JoinAllRoomsConfirmationView(context: viewModel.context)
            .previewDisplayName("Default")
    }
}
