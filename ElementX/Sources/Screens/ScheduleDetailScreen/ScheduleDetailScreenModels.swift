//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

enum ScheduleDetailScreenViewModelAction {
    case dismiss
    case deleted
}

struct ScheduleDetailScreenViewState: BindableState {
    var schedule: Schedule
    var history: [ScheduleHistoryEntry] = []
    var isLoadingHistory = true
    var isAdmin = false
    var bindings = ScheduleDetailScreenStateBindings()
}

struct ScheduleDetailScreenStateBindings {
    var alertInfo: AlertInfo<ScheduleDetailAlertType>?
}

enum ScheduleDetailAlertType: Hashable {
    case deleteConfirmation
    case error(String)
}

enum ScheduleDetailScreenViewAction {
    case delete
    case confirmDelete
    case run
    case pause
    case resume
}
