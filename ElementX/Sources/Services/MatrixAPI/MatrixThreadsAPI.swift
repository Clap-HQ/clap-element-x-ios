//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

/// Implementation of Matrix Threads API endpoints using direct REST calls
/// Uses the /threads endpoint (MSC3856) to get all threads in a room
class MatrixThreadsAPI: RESTAPIClient, MatrixThreadsAPIProtocol {
    // MARK: - MatrixThreadsAPIProtocol

    func fetchThreads(roomID: String,
                      from: String?,
                      include: ThreadIncludeFilter,
                      limit: Int) async -> Result<ThreadListResponse, RESTAPIError> {
        var queryParams: [String: String] = [
            "include": include.rawValue,
            "limit": String(limit)
        ]
        if let from {
            queryParams["from"] = from
        }

        let request = RESTAPIRequest(
            method: .get,
            pathTemplate: "/_matrix/client/v1/rooms/%@/threads",
            pathParameters: [roomID],
            queryParameters: queryParams
        )
        return await execute(request)
    }
}
