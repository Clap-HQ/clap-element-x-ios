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
    
    @State private var isTimelineReady = false
    
    init(context: AgentScreenViewModelType.Context,
         timelineContext: TimelineViewModelType.Context,
         composerToolbar: ComposerToolbar) {
        self.context = context
        self.timelineContext = timelineContext
        self.composerToolbar = composerToolbar
    }
        
    var body: some View {
        TimelineView(timelineContext: timelineContext)
            .opacity(isTimelineReady ? 1 : 0)
            .animation(.easeIn(duration: 0.15), value: isTimelineReady)
            .task {
                try? await Task.sleep(for: .milliseconds(100))
                isTimelineReady = true
            }
            .environment(\.timelineBackgroundColor, .compound.bgCanvasClap)
            .environment(\.isTimelineMenuMinimal, true)
            .environment(\.hidesTimelineDecorations, true)
            .background(.compound.bgCanvasClap)
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
                    .background(Color.compound.bgCanvasClap.ignoresSafeArea())
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
        
        ToolbarItem(placement: .primaryAction) {
            Button { context.send(viewAction: .showSchedules) } label: {
                Image(systemName: "calendar.badge.clock")
            }
        }
    }
    
    private var isAtBottomAndLive: Bool {
        timelineContext.isScrolledToBottom && timelineContext.viewState.timelineState.isLive
    }
}
