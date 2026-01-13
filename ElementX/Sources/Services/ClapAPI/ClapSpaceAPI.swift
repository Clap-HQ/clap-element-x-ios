//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

/// Implementation of Clap Space API endpoints
class ClapSpaceAPI: ClapSpaceAPIProtocol {
    private let homeserverURL: String
    private let accessTokenProvider: () -> String?
    private let session: URLSession

    init(homeserverURL: String, accessTokenProvider: @escaping () -> String?, session: URLSession = .shared) {
        self.homeserverURL = homeserverURL
        self.accessTokenProvider = accessTokenProvider
        self.session = session
    }

    // MARK: - ClapSpaceAPIProtocol

    func removeMemberFromAllChildRooms(spaceID: String, userID: String, reason: String?) async -> Result<ClapSpaceMemberRemovalResult, ClapAPIError> {
        guard let encodedSpaceID = spaceID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return .failure(.invalidURL)
        }

        let baseURL = homeserverURL.hasSuffix("/") ? String(homeserverURL.dropLast()) : homeserverURL
        let urlString = "\(baseURL)/_clap/client/v1/spaces/\(encodedSpaceID)/remove"

        guard let url = URL(string: urlString) else {
            MXLog.error("Invalid URL: \(urlString)")
            return .failure(.invalidURL)
        }

        guard let accessToken = accessTokenProvider() else {
            MXLog.error("No access token available")
            return .failure(.unauthorized)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = RemoveMemberRequest(userID: userID, reason: reason)
        do {
            let bodyData = try JSONEncoder().encode(body)
            request.httpBody = bodyData
            let bodyString = String(data: bodyData, encoding: .utf8) ?? "nil"
            MXLog.info("Calling Clap space member removal API: URL=\(urlString), body=\(bodyString)")
        } catch {
            MXLog.error("Failed to encode request body: \(error)")
            return .failure(.encodingError)
        }

        do {
            let (data, response) = try await session.dataWithRetry(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.networkError(NSError(domain: "ClapSpaceAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
            }

            let responseBody = String(data: data, encoding: .utf8) ?? "nil"
            MXLog.info("Clap space member removal API response: status=\(httpResponse.statusCode), body=\(responseBody)")

            switch httpResponse.statusCode {
            case 200:
                do {
                    let result = try JSONDecoder().decode(ClapSpaceMemberRemovalResult.self, from: data)
                    MXLog.info("Successfully removed user from \(result.removed.count) rooms, failed for \(result.failed.count) rooms")
                    if !result.failed.isEmpty {
                        MXLog.info("Failed rooms: \(result.failed.map { "\($0.roomId): \($0.error)" }.joined(separator: ", "))")
                    }
                    return .success(result)
                } catch {
                    MXLog.error("Failed to decode response: \(error)")
                    return .failure(.decodingError)
                }
            case 401:
                MXLog.error("Unauthorized when calling Clap space API")
                return .failure(.unauthorized)
            case 403:
                MXLog.error("Forbidden when calling Clap space API - insufficient permissions")
                return .failure(.forbidden)
            case 404:
                MXLog.error("Space not found: \(spaceID)")
                return .failure(.notFound)
            default:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                MXLog.error("HTTP error \(httpResponse.statusCode): \(errorMessage)")
                return .failure(.httpError(statusCode: httpResponse.statusCode, message: errorMessage))
            }
        } catch {
            MXLog.error("Network error: \(error)")
            return .failure(.networkError(error))
        }
    }
}

// MARK: - Request Types

private struct RemoveMemberRequest: Encodable {
    let userID: String
    let reason: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case reason
    }
}
