//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct ScheduleDetailScreen: View {
    @Bindable var context: ScheduleDetailScreenViewModel.Context
    
    private var schedule: Schedule { context.viewState.schedule }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                infoSection
                promptSection
                historySection
            }
            .padding(16)
        }
        .navigationTitle(L10n.screenScheduleDetailTitle)
        .navigationBarTitleDisplayMode(.inline)
        .background(.compound.bgCanvasDefault)
        .toolbar { toolbar }
        .alert(item: $context.alertInfo)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("#\(schedule.id)")
                    .font(.compound.bodySMSemibold)
                    .foregroundColor(.compound.textSecondary)
                
                ScheduleStatusBadge(status: schedule.status)
                
                if schedule.isDM {
                    ScheduleDMBadge()
                }
            }
            
            Text(schedule.name)
                .font(.compound.bodyLGSemibold)
                .foregroundColor(.compound.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.compound.bgSubtleSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                if context.viewState.isAdmin {
                    Section {
                        Button {
                            context.send(viewAction: .run)
                        } label: {
                            Label(L10n.screenScheduleDetailActionRun, systemImage: "play.fill")
                        }
                        .disabled(schedule.status != .active)
                        
                        if schedule.status == .active {
                            Button {
                                context.send(viewAction: .pause)
                            } label: {
                                Label(L10n.screenScheduleDetailActionPause, systemImage: "pause.fill")
                            }
                        } else if schedule.status == .paused {
                            Button {
                                context.send(viewAction: .resume)
                            } label: {
                                Label(L10n.screenScheduleDetailActionResume, systemImage: "play.fill")
                            }
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        context.send(viewAction: .delete)
                    } label: {
                        Label(L10n.a11yDelete, systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
    
    private var infoSection: some View {
        VStack(spacing: 0) {
            ScheduleInfoRow(label: L10n.screenScheduleDetailCronExpression, value: schedule.cronExpression, isMonospaced: true)
            ScheduleInfoRow(label: L10n.screenScheduleDetailTimezone, value: schedule.timezone)
            ScheduleInfoRow(label: L10n.screenScheduleDetailRoomId, value: schedule.roomID, isMonospaced: true)
            ScheduleInfoRow(label: L10n.screenScheduleDetailCreatedBy, value: schedule.userID, isMonospaced: true)
            if let targetUser = schedule.targetUser {
                ScheduleInfoRow(label: L10n.screenScheduleDetailTargetUser, value: targetUser)
            }
            ScheduleInfoRow(label: L10n.screenScheduleDetailRunCount, value: L10n.screenScheduleDetailRunCountValue(schedule.runCount))
            if let lastRunAt = schedule.lastRunAt {
                ScheduleInfoRow(label: L10n.screenScheduleDetailLastRun, value: lastRunAt.formatted())
            }
            ScheduleInfoRow(label: L10n.screenScheduleDetailCreatedAt, value: schedule.createdAt.formatted())
            ScheduleInfoRow(label: L10n.screenScheduleDetailUpdatedAt, value: schedule.updatedAt.formatted())
        }
        .padding(.vertical, 8)
        .background(Color.compound.bgSubtleSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var promptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.screenScheduleDetailSectionPrompt)
                .font(.compound.bodyLGSemibold)
                .foregroundColor(.compound.textPrimary)
            
            Text(schedule.prompt)
                .font(.compound.bodyMD)
                .foregroundColor(.compound.textPrimary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.compound.bgCanvasDefault)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(16)
        .background(Color.compound.bgSubtleSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.screenScheduleDetailSectionHistory)
                .font(.compound.bodyLGSemibold)
                .foregroundColor(.compound.textPrimary)
            
            if context.viewState.isLoadingHistory {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else if context.viewState.history.isEmpty {
                Text(L10n.screenScheduleDetailHistoryEmpty)
                    .font(.compound.bodyMD)
                    .foregroundColor(.compound.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                VStack(spacing: 8) {
                    ForEach(context.viewState.history) { entry in
                        ScheduleHistoryRow(entry: entry)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.compound.bgSubtleSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
