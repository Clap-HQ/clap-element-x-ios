//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

typealias ClapDeveloperModeScreenViewModelType = StateStoreViewModelV2<ClapDeveloperModeScreenViewState, ClapDeveloperModeScreenViewAction>

protocol ClapDeveloperModeScreenViewModelProtocol {
    var actions: AnyPublisher<ClapDeveloperModeScreenViewModelAction, Never> { get }
    var context: ClapDeveloperModeScreenViewModelType.Context { get }
}

class ClapDeveloperModeScreenViewModel: ClapDeveloperModeScreenViewModelType, ClapDeveloperModeScreenViewModelProtocol {
    private var actionsSubject: PassthroughSubject<ClapDeveloperModeScreenViewModelAction, Never> = .init()

    var actions: AnyPublisher<ClapDeveloperModeScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(clapDeveloperModeSettings: ClapDeveloperModeSettings) {
        let bindings = ClapDeveloperModeScreenViewStateBindings(clapDeveloperModeSettings: clapDeveloperModeSettings)
        let state = ClapDeveloperModeScreenViewState(bindings: bindings)

        super.init(initialViewState: state)
    }

    override func process(viewAction: ClapDeveloperModeScreenViewAction) { }
}
