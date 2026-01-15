//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

/// Unified error type for all REST API calls (Matrix and Clap)
enum RESTAPIError: Error, LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case networkError(String)
    case httpError(statusCode: Int, message: String)
    case unauthorized
    case forbidden
    case notFound
    case encodingError
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            L10n.errorUnknown
        case .invalidResponse:
            L10n.errorUnknown
        case .networkError(let message):
            message
        case .httpError(let statusCode, let message):
            "HTTP \(statusCode): \(message)"
        case .unauthorized:
            L10n.errorUnknown
        case .forbidden:
            L10n.errorUnknown
        case .notFound:
            L10n.errorUnknown
        case .encodingError:
            L10n.errorUnknown
        case .decodingError:
            L10n.errorUnknown
        }
    }

    static func == (lhs: RESTAPIError, rhs: RESTAPIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.encodingError, .encodingError),
             (.decodingError, .decodingError):
            true
        case (.networkError(let lhsMsg), .networkError(let rhsMsg)):
            lhsMsg == rhsMsg
        case (.httpError(let lhsCode, let lhsMsg), .httpError(let rhsCode, let rhsMsg)):
            lhsCode == rhsCode && lhsMsg == rhsMsg
        default:
            false
        }
    }
}
