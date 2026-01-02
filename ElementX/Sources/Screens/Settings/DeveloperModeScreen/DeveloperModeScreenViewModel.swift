//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

typealias DeveloperModeScreenViewModelType = StateStoreViewModelV2<DeveloperModeScreenViewState, DeveloperModeScreenViewAction>

protocol DeveloperModeScreenViewModelProtocol {
    var actions: AnyPublisher<DeveloperModeScreenViewModelAction, Never> { get }
    var context: DeveloperModeScreenViewModelType.Context { get }
}

class DeveloperModeScreenViewModel: DeveloperModeScreenViewModelType, DeveloperModeScreenViewModelProtocol {
    private var actionsSubject: PassthroughSubject<DeveloperModeScreenViewModelAction, Never> = .init()

    var actions: AnyPublisher<DeveloperModeScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(developerModeSettings: DeveloperModeSettings) {
        let bindings = DeveloperModeScreenViewStateBindings(developerModeSettings: developerModeSettings)
        let state = DeveloperModeScreenViewState(bindings: bindings)

        super.init(initialViewState: state)
    }

    override func process(viewAction: DeveloperModeScreenViewAction) { }
}
