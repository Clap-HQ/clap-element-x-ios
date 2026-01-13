//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

/// Errors that can occur when calling Clap API endpoints
enum ClapAPIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case httpError(statusCode: Int, message: String)
    case unauthorized
    case forbidden
    case notFound
    case encodingError
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let statusCode, let message):
            return "HTTP error \(statusCode): \(message)"
        case .unauthorized:
            return "Unauthorized"
        case .forbidden:
            return "Forbidden - insufficient permissions"
        case .notFound:
            return "Not found"
        case .encodingError:
            return "Failed to encode request body"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
