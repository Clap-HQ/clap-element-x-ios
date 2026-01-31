//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct AgentScreen: View {
    @Bindable private var context: AgentScreenViewModelType.Context
    @ObservedObject private var timelineContext: TimelineViewModelType.Context
    private let composerToolbar: ComposerToolbar
    
    init(context: AgentScreenViewModelType.Context,
         timelineContext: TimelineViewModelType.Context,
         composerToolbar: ComposerToolbar) {
        self.context = context
        self.timelineContext = timelineContext
        self.composerToolbar = composerToolbar
    }
        
    var body: some View {
        TimelineView(timelineContext: timelineContext)
            .environment(\.timelineBackgroundColor, .compound.bgCanvasDefault)
            .environment(\.isTimelineMenuMinimal, true)
            .background(.compound.bgCanvasDefault)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar { toolbar }
            .toolbarBackground(.visible, for: .navigationBar)
            .timelineMediaPreview(viewModel: $context.mediaPreviewViewModel)
            .overlay(alignment: .bottomTrailing) {
                TimelineScrollToBottomButton(isVisible: isAtBottomAndLive) {
                    timelineContext.send(viewAction: .scrollToBottom)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                composer
                    .padding(.top, 8)
                    .background(Color.compound.bgCanvasDefault.ignoresSafeArea())
                    .environmentObject(timelineContext)
                    .environment(\.timelineContext, timelineContext)
                    .environment(\.shouldAutomaticallyLoadImages, !timelineContext.viewState.hideTimelineMedia)
            }
    }
    
    @ViewBuilder
    private var composer: some View {
        if context.viewState.canSendMessage {
            composerToolbar
        } else {
            ComposerDisabledView()
        }
    }
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button { context.send(viewAction: .dismiss) } label: {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .principal) {
            RoomHeaderView(roomName: context.viewState.roomTitle,
                           roomAvatar: context.viewState.roomAvatar,
                           mediaProvider: context.mediaProvider)
                .contentShape(.rect)
        }
    }
    
    private var isAtBottomAndLive: Bool {
        timelineContext.isScrolledToBottom && timelineContext.viewState.timelineState.isLive
    }
}
