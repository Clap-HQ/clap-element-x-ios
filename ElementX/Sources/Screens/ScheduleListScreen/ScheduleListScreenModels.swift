//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

enum ScheduleListScreenViewModelAction {
    case showScheduleDetail(Schedule)
    case showCreateSchedule
}

struct ScheduleListScreenViewState: BindableState {
    var schedules: [Schedule] = []
    var isLoading = true
    var isAdmin = false
    var bindings = ScheduleListScreenStateBindings()
    
    var filteredSchedules: [Schedule] {
        switch bindings.selectedFilter {
        case .all:
            return schedules.filter { $0.status != .cancelled }
        case .active:
            return schedules.filter { $0.status == .active }
        case .cancelled:
            return schedules.filter { $0.status == .cancelled }
        }
    }
    
    var isEmpty: Bool {
        !isLoading && schedules.isEmpty
    }
    
    var isFilteredEmpty: Bool {
        !isLoading && !schedules.isEmpty && filteredSchedules.isEmpty
    }
}

struct ScheduleListScreenStateBindings {
    var selectedFilter: ScheduleListFilter = .all
    var alertInfo: AlertInfo<ScheduleListAlertType>?
}

enum ScheduleListFilter: String, CaseIterable {
    case all
    case active
    case cancelled
    
    var displayName: String {
        switch self {
        case .all: return L10n.screenScheduleListFilterAll
        case .active: return L10n.screenScheduleListFilterActive
        case .cancelled: return L10n.screenScheduleListFilterCancelled
        }
    }
}

enum ScheduleListAlertType: Hashable {
    case deleteConfirmation(Schedule)
    case error(String)
}

enum ScheduleListScreenViewAction {
    case refresh
    case selectSchedule(Schedule)
    case deleteSchedule(Schedule)
    case confirmDelete(Schedule)
    case createSchedule
}
