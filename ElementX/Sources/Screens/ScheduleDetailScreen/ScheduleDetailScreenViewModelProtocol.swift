//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine

// sourcery: AutoMockable
@MainActor
protocol ScheduleDetailScreenViewModelProtocol {
    var actions: AnyPublisher<ScheduleDetailScreenViewModelAction, Never> { get }
    var context: ScheduleDetailScreenViewModelType.Context { get }
}
