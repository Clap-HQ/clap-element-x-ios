//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

/// Service for fetching thread lists via Matrix REST API
/// Uses the /threads endpoint (MSC3856) to get all threads in a room
class ThreadsService {
    private let homeserverURL: String
    private let accessTokenProvider: () -> String?
    private let session: URLSession

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

    /// Fetch all threads in a room
    /// - Parameters:
    ///   - roomID: The room ID to fetch threads from
    ///   - from: Pagination token to continue from (optional)
    ///   - include: Filter for threads - "all" or "participated"
    ///   - limit: Maximum number of threads to return (default 20)
    /// - Returns: Result containing ThreadListResponse or ThreadsServiceError
    func fetchThreads(roomID: String,
                      from: String? = nil,
                      include: ThreadIncludeFilter = .all,
                      limit: Int = 20) async -> Result<ThreadListResponse, ThreadsServiceError> {
        guard let encodedRoomID = roomID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return .failure(.invalidURL)
        }

        let baseURL = homeserverURL.hasSuffix("/") ? String(homeserverURL.dropLast()) : homeserverURL
        var urlString = "\(baseURL)/_matrix/client/v1/rooms/\(encodedRoomID)/threads"

        // Build query parameters
        var queryItems: [String] = []
        if let from {
            queryItems.append("from=\(from)")
        }
        queryItems.append("include=\(include.rawValue)")
        queryItems.append("limit=\(limit)")

        if !queryItems.isEmpty {
            urlString += "?" + queryItems.joined(separator: "&")
        }

        guard let url = URL(string: urlString) else {
            MXLog.error("Invalid URL: \(urlString)")
            return .failure(.invalidURL)
        }

        guard let accessToken = accessTokenProvider() else {
            MXLog.error("No access token available")
            return .failure(.unauthorized)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        MXLog.info("Fetching threads: \(urlString)")

        do {
            let (data, response) = try await session.dataWithRetry(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.networkError(NSError(domain: "ThreadsService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
            }

            switch httpResponse.statusCode {
            case 200:
                // Log the raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    MXLog.info("Threads API response: \(jsonString)")
                }

                do {
                    let decoder = JSONDecoder()
                    let threadResponse = try decoder.decode(ThreadListResponse.self, from: data)
                    MXLog.info("Successfully fetched \(threadResponse.chunk.count) threads for room \(roomID)")
                    return .success(threadResponse)
                } catch {
                    MXLog.error("Failed to decode thread response: \(error)")
                    return .failure(.decodingError(error))
                }
            case 401:
                MXLog.error("Unauthorized when fetching threads")
                return .failure(.unauthorized)
            case 403:
                MXLog.error("Forbidden when fetching threads - insufficient permissions")
                return .failure(.forbidden)
            case 404:
                // The /threads endpoint might not be available on older homeservers
                MXLog.warning("Threads endpoint not found - homeserver may not support MSC3856")
                return .failure(.notSupported)
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

// MARK: - Types

enum ThreadIncludeFilter: String {
    /// Include all threads
    case all
    /// Include only threads the user has participated in
    case participated
}

enum ThreadsServiceError: Error {
    case invalidURL
    case unauthorized
    case forbidden
    case notFound
    case notSupported
    case httpError(statusCode: Int, message: String)
    case networkError(Error)
    case decodingError(Error)
    case encodingError
}

/// Response from the /threads API endpoint
struct ThreadListResponse: Decodable {
    /// Array of thread root events
    let chunk: [ThreadRootEvent]
    /// Pagination token for fetching more threads
    let nextBatch: String?

    enum CodingKeys: String, CodingKey {
        case chunk
        case nextBatch = "next_batch"
    }
}

/// A thread root event from the API
struct ThreadRootEvent: Decodable, Identifiable {
    let eventId: String
    let sender: String
    let originServerTs: UInt64
    let type: String
    let content: ThreadEventContent?
    let unsigned: ThreadEventUnsigned?

    var id: String { eventId }

    /// Timestamp as Date
    var timestamp: Date {
        Date(timeIntervalSince1970: TimeInterval(originServerTs) / 1000)
    }

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case sender
        case originServerTs = "origin_server_ts"
        case type
        case content
        case unsigned
    }
}

/// Content of a thread root event
struct ThreadEventContent: Decodable {
    let body: String?
    let msgtype: String?
    let format: String?
    let formattedBody: String?

    enum CodingKeys: String, CodingKey {
        case body
        case msgtype
        case format
        case formattedBody = "formatted_body"
    }

    /// Get display text for this content
    var displayText: String {
        body ?? L10n.commonMessage
    }
}

/// Unsigned data for a thread event
struct ThreadEventUnsigned: Decodable {
    let relations: ThreadRelations?

    enum CodingKeys: String, CodingKey {
        case relations = "m.relations"
    }
}

/// Relations data containing thread summary
struct ThreadRelations: Decodable {
    let thread: ThreadSummaryData?

    enum CodingKeys: String, CodingKey {
        case thread = "m.thread"
    }
}

/// Thread summary data from the API
struct ThreadSummaryData: Decodable {
    let count: Int
    let latestEvent: ThreadLatestEvent?
    let currentUserParticipated: Bool

    enum CodingKeys: String, CodingKey {
        case count
        case latestEvent = "latest_event"
        case currentUserParticipated = "current_user_participated"
    }
}

/// Latest event in a thread
struct ThreadLatestEvent: Decodable {
    let eventId: String
    let sender: String
    let originServerTs: UInt64
    let type: String?
    let content: ThreadEventContent?

    var timestamp: Date {
        Date(timeIntervalSince1970: TimeInterval(originServerTs) / 1000)
    }

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case sender
        case originServerTs = "origin_server_ts"
        case type
        case content
    }
}
