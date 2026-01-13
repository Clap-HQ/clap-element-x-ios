//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

/// Service for direct Matrix REST API calls (/_matrix/...)
/// Used when MatrixRustSDK doesn't expose certain APIs
class MatrixAPIService: MatrixAPIServiceProtocol {
    private let homeserverURL: String
    private let accessTokenProvider: () -> String?
    private let session: URLSession

    private(set) lazy var spaces: MatrixSpaceAPIProtocol = MatrixSpaceAPI(
        homeserverURL: homeserverURL,
        accessTokenProvider: accessTokenProvider,
        session: session
    )

    init(homeserverURL: String, accessTokenProvider: @escaping () -> String?, session: URLSession = .shared) {
        self.homeserverURL = homeserverURL
        self.accessTokenProvider = accessTokenProvider
        self.session = session
    }
}
