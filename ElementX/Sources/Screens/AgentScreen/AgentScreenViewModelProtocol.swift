//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine

@MainActor
protocol AgentScreenViewModelProtocol {
    var actionsPublisher: AnyPublisher<AgentScreenViewModelAction, Never> { get }
    var context: AgentScreenViewModelType.Context { get }
    
    func stop()
    
    func displayMediaPreview(_ mediaPreviewViewModel: TimelineMediaPreviewViewModel)
}
