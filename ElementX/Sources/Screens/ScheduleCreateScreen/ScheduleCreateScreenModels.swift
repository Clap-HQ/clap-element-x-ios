//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

enum ScheduleCreateScreenViewModelAction {
    case dismiss
    case created(Schedule)
}

struct ScheduleCreateScreenViewState: BindableState {
    var rooms: [RoomSummary] = []
    var directMessages: [RoomSummary] = []
    var isSubmitting = false
    var bindings = ScheduleCreateScreenStateBindings()
    
    var canSubmit: Bool {
        !bindings.name.isEmpty &&
        !bindings.cronExpression.isEmpty &&
        bindings.selectedRoom != nil &&
        !bindings.prompt.isEmpty &&
        !isSubmitting
    }
}

struct ScheduleCreateScreenStateBindings {
    var name = ""
    var cronExpression = ""
    var selectedTimezone: ScheduleTimezone = .asiaSeoul
    var selectedRoom: RoomSummary?
    var prompt = ""
    var alertInfo: AlertInfo<ScheduleCreateAlertType>?
    var showRoomPicker = false
}

enum ScheduleTimezone: String, CaseIterable {
    case asiaSeoul = "Asia/Seoul"
    case utc = "UTC"
    case americaNewYork = "America/New_York"
    case americaLosAngeles = "America/Los_Angeles"
    case europeLondon = "Europe/London"
    
    var displayName: String {
        switch self {
        case .asiaSeoul: return "Asia/Seoul (KST)"
        case .utc: return "UTC"
        case .americaNewYork: return "America/New_York (EST)"
        case .americaLosAngeles: return "America/Los_Angeles (PST)"
        case .europeLondon: return "Europe/London (GMT)"
        }
    }
}

enum ScheduleCreateAlertType: Hashable {
    case error(String)
}

enum ScheduleCreateScreenViewAction {
    case selectRoom(RoomSummary)
    case showRoomPicker
    case hideRoomPicker
    case submit
    case cancel
}
