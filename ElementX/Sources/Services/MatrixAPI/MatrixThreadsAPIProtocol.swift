//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

/// Filter for which threads to include
enum ThreadIncludeFilter: String {
    /// Include all threads
    case all
    /// Include only threads the user has participated in
    case participated
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

// sourcery: AutoMockable
protocol MatrixThreadsAPIProtocol {
    /// Fetch all threads in a room
    /// - Parameters:
    ///   - roomID: The room ID to fetch threads from
    ///   - from: Pagination token to continue from (optional)
    ///   - include: Filter for threads - "all" or "participated"
    ///   - limit: Maximum number of threads to return (default 20)
    /// - Returns: Result containing ThreadListResponse or RESTAPIError
    func fetchThreads(roomID: String,
                      from: String?,
                      include: ThreadIncludeFilter,
                      limit: Int) async -> Result<ThreadListResponse, RESTAPIError>
}

extension MatrixThreadsAPIProtocol {
    func fetchThreads(roomID: String,
                      from: String? = nil,
                      include: ThreadIncludeFilter = .all,
                      limit: Int = 20) async -> Result<ThreadListResponse, RESTAPIError> {
        await fetchThreads(roomID: roomID, from: from, include: include, limit: limit)
    }
}
