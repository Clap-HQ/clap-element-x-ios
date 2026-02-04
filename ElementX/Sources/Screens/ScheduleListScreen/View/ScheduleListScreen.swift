//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct ScheduleListScreen: View {
    @Bindable var context: ScheduleListScreenViewModel.Context
    
    var body: some View {
        mainContent
            .navigationTitle(L10n.screenScheduleListTitle)
            .navigationBarTitleDisplayMode(.inline)
            .background(.compound.bgCanvasDefault)
            .refreshable { context.send(viewAction: .refresh) }
            .alert(item: $context.alertInfo)
            .toolbar { toolbar }
    }
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            if context.viewState.isAdmin {
                Button {
                    context.send(viewAction: .createSchedule)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if context.viewState.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if context.viewState.isEmpty {
            emptyStateView
        } else {
            scheduleList
        }
    }
    
    private var scheduleList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                filterTabs
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .transaction { $0.animation = nil }
                
                if context.viewState.isFilteredEmpty {
                    filteredEmptyStateView
                } else {
                    ForEach(context.viewState.filteredSchedules) { schedule in
                        ScheduleListCell(
                            schedule: schedule,
                            onTap: { context.send(viewAction: .selectSchedule(schedule)) }
                        )
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: context.viewState.filteredSchedules)
        }
    }
    
    private var filteredEmptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 32))
                .foregroundColor(.compound.iconTertiary)
            
            Text(L10n.screenScheduleListFilterEmpty)
                .font(.compound.bodyMD)
                .foregroundColor(.compound.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
    
    private var filterTabs: some View {
        HStack(spacing: 6) {
            ForEach(ScheduleListFilter.allCases, id: \.self) { filter in
                ScheduleFilterButton(
                    title: filter.displayName,
                    isActive: context.viewState.bindings.selectedFilter == filter
                ) {
                    context.selectedFilter = filter
                }
            }
            Spacer()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 48))
                .foregroundColor(.compound.iconTertiary)
            
            Text(L10n.screenScheduleListEmptyTitle)
                .font(.compound.bodyLG)
                .foregroundColor(.compound.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
