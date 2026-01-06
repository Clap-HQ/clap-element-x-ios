//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

/// Service for managing space-child relationships via Matrix REST API
/// Used when MatrixRustSDK doesn't expose state event APIs
class SpaceChildService: SpaceChildServiceProtocol {
    private let homeserverURL: String
    private let accessTokenProvider: () -> String?
    private let session: URLSession

    /// The homeserver domain extracted from the URL, used for the "via" field
    private var homeserverDomain: String {
        URL(string: homeserverURL)?.host ?? homeserverURL
    }

    /// Initialize with an access token provider closure that fetches the current token
    /// - Parameters:
    ///   - homeserverURL: The homeserver base URL
    ///   - accessTokenProvider: A closure that returns the current access token
    ///   - session: URLSession to use for requests
    init(homeserverURL: String, accessTokenProvider: @escaping () -> String?, session: URLSession = .shared) {
        self.homeserverURL = homeserverURL
        self.accessTokenProvider = accessTokenProvider
        self.session = session
    }

    // MARK: - SpaceChildServiceProtocol

    func addChildToSpace(spaceID: String, childRoomID: String, suggested: Bool) async -> Result<Void, SpaceChildServiceError> {
        let body = SpaceChildContent(via: [homeserverDomain], suggested: suggested)
        return await sendStateEvent(roomID: spaceID, eventType: "m.space.child", stateKey: childRoomID, content: body)
    }

    func removeChildFromSpace(spaceID: String, childRoomID: String) async -> Result<Void, SpaceChildServiceError> {
        // Sending an empty object removes the relationship
        let body = EmptyContent()
        return await sendStateEvent(roomID: spaceID, eventType: "m.space.child", stateKey: childRoomID, content: body)
    }

    func setSpaceParent(roomID: String, spaceID: String, canonical: Bool) async -> Result<Void, SpaceChildServiceError> {
        let body = SpaceParentContent(via: [homeserverDomain], canonical: canonical)
        return await sendStateEvent(roomID: roomID, eventType: "m.space.parent", stateKey: spaceID, content: body)
    }

    func setRestrictedJoinRule(roomID: String, spaceID: String) async -> Result<Void, SpaceChildServiceError> {
        let allowRule = JoinRuleAllowCondition(type: "m.room_membership", roomId: spaceID)
        let body = JoinRulesContent(joinRule: "restricted", allow: [allowRule])
        return await sendStateEvent(roomID: roomID, eventType: "m.room.join_rules", stateKey: "", content: body)
    }

    func setPublicJoinRule(roomID: String) async -> Result<Void, SpaceChildServiceError> {
        let body = JoinRulesContent(joinRule: "public", allow: nil)
        return await sendStateEvent(roomID: roomID, eventType: "m.room.join_rules", stateKey: "", content: body)
    }

    // MARK: - Private

    private func sendStateEvent<T: Encodable>(roomID: String,
                                               eventType: String,
                                               stateKey: String,
                                               content: T) async -> Result<Void, SpaceChildServiceError> {
        // URL encode the room ID and state key (they contain special characters like ! and :)
        guard let encodedRoomID = roomID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let encodedStateKey = stateKey.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return .failure(.invalidURL)
        }

        // Remove trailing slash from homeserver URL if present to avoid double slashes
        let baseURL = homeserverURL.hasSuffix("/") ? String(homeserverURL.dropLast()) : homeserverURL
        let urlString = "\(baseURL)/_matrix/client/v3/rooms/\(encodedRoomID)/state/\(eventType)/\(encodedStateKey)"

        guard let url = URL(string: urlString) else {
            MXLog.error("Invalid URL: \(urlString)")
            return .failure(.invalidURL)
        }

        guard let accessToken = accessTokenProvider() else {
            MXLog.error("No access token available")
            return .failure(.unauthorized)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let bodyData = try JSONEncoder().encode(content)
            request.httpBody = bodyData
            let bodyString = String(data: bodyData, encoding: .utf8) ?? "nil"
            MXLog.info("Sending \(eventType) state event: URL=\(urlString), body=\(bodyString)")
        } catch {
            MXLog.error("Failed to encode request body: \(error)")
            return .failure(.encodingError)
        }

        do {
            let (data, response) = try await session.dataWithRetry(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.networkError(NSError(domain: "SpaceChildService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
            }

            switch httpResponse.statusCode {
            case 200:
                MXLog.info("Successfully sent \(eventType) state event for room \(roomID)")
                return .success(())
            case 401:
                MXLog.error("Unauthorized when sending state event")
                return .failure(.unauthorized)
            case 403:
                MXLog.error("Forbidden when sending state event - insufficient permissions")
                return .failure(.forbidden)
            case 404:
                MXLog.error("Room not found: \(roomID)")
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

// MARK: - Content Types

/// Content for m.space.child state event
private struct SpaceChildContent: Encodable {
    let via: [String]
    let suggested: Bool
}

/// Content for m.space.parent state event
private struct SpaceParentContent: Encodable {
    let via: [String]
    let canonical: Bool
}

/// Content for m.room.join_rules state event
private struct JoinRulesContent: Encodable {
    let joinRule: String
    let allow: [JoinRuleAllowCondition]?

    enum CodingKeys: String, CodingKey {
        case joinRule = "join_rule"
        case allow
    }
}

/// Allow condition for restricted join rules
private struct JoinRuleAllowCondition: Encodable {
    let type: String
    let roomId: String

    enum CodingKeys: String, CodingKey {
        case type
        case roomId = "room_id"
    }
}

/// Empty content for removing state events
private struct EmptyContent: Encodable { }
