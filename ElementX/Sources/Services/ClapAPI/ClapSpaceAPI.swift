//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

/// Implementation of Clap Space API endpoints
class ClapSpaceAPI: RESTAPIClient, ClapSpaceAPIProtocol {
    // MARK: - ClapSpaceAPIProtocol

    func removeMemberFromAllChildRooms(spaceID: String, userID: String) async -> Result<ClapSpaceMemberRemovalResult, RESTAPIError> {
        let request = RESTAPIRequest(
            method: .post,
            pathTemplate: "/_clap/client/v1/spaces/%@/remove",
            pathParameters: [spaceID],
            body: RemoveMemberRequest(userID: userID)
        )
        return await execute(request)
    }

    func joinAllChildRooms(spaceID: String) async -> Result<ClapSpaceJoinAllResult, RESTAPIError> {
        let request = RESTAPIRequest(
            method: .post,
            pathTemplate: "/_clap/client/v1/spaces/%@/join-all",
            pathParameters: [spaceID]
        )
        return await execute(request)
    }
}

// MARK: - Request Types

private struct RemoveMemberRequest: Encodable {
    let userID: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
    }
}
