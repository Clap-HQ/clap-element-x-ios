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

    func removeMemberFromAllChildRooms(spaceID: String, userID: String) async -> Result<ClapSpaceMemberRemovalResult, ClapAPIError> {
        guard let encodedSpaceID = spaceID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return .failure(.invalidURL)
        }

        let baseURL = homeserverURL.hasSuffix("/") ? String(homeserverURL.dropLast()) : homeserverURL
        let urlString = "\(baseURL)/_clap/client/v1/spaces/\(encodedSpaceID)/remove"

        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }

        guard let accessToken = accessTokenProvider() else {
            return .failure(.unauthorized)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = RemoveMemberRequest(userID: userID)
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return .failure(.encodingError)
        }

        do {
            let (data, response) = try await session.dataWithRetry(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.networkError(NSError(domain: "ClapSpaceAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
            }

            switch httpResponse.statusCode {
            case 200:
                do {
                    let result = try JSONDecoder().decode(ClapSpaceMemberRemovalResult.self, from: data)
                    return .success(result)
                } catch {
                    MXLog.error("Failed to decode Clap space member removal response")
                    return .failure(.decodingError)
                }
            case 401:
                MXLog.error("Unauthorized when calling Clap space API")
                return .failure(.unauthorized)
            case 403:
                MXLog.error("Forbidden when calling Clap space API")
                return .failure(.forbidden)
            case 404:
                MXLog.error("Space not found: \(spaceID)")
                return .failure(.notFound)
            default:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                MXLog.error("Clap space API HTTP error \(httpResponse.statusCode)")
                return .failure(.httpError(statusCode: httpResponse.statusCode, message: errorMessage))
            }
        } catch {
            MXLog.error("Clap space API network error: \(error)")
            return .failure(.networkError(error))
        }
    }
}

// MARK: - Request Types

private struct RemoveMemberRequest: Encodable {
    let userID: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
    }
}
