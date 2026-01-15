//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

/// Implementation of Matrix Space API endpoints using direct REST calls
/// Used when MatrixRustSDK doesn't expose state event APIs
class MatrixSpaceAPI: RESTAPIClient, MatrixSpaceAPIProtocol {
    // MARK: - MatrixSpaceAPIProtocol

    func addChildToSpace(spaceID: String, childRoomID: String, suggested: Bool) async -> Result<Void, RESTAPIError> {
        let request = RESTAPIRequest(
            method: .put,
            pathTemplate: "/_matrix/client/v3/rooms/%@/state/m.space.child/%@",
            pathParameters: [spaceID, childRoomID],
            body: SpaceChildContent(via: [homeserverDomain], suggested: suggested)
        )
        return await execute(request)
    }

    func removeChildFromSpace(spaceID: String, childRoomID: String) async -> Result<Void, RESTAPIError> {
        let request = RESTAPIRequest(
            method: .put,
            pathTemplate: "/_matrix/client/v3/rooms/%@/state/m.space.child/%@",
            pathParameters: [spaceID, childRoomID],
            body: EmptyStateContent()
        )
        return await execute(request)
    }

    func setSpaceParent(roomID: String, spaceID: String, canonical: Bool) async -> Result<Void, RESTAPIError> {
        let request = RESTAPIRequest(
            method: .put,
            pathTemplate: "/_matrix/client/v3/rooms/%@/state/m.space.parent/%@",
            pathParameters: [roomID, spaceID],
            body: SpaceParentContent(via: [homeserverDomain], canonical: canonical)
        )
        return await execute(request)
    }

    func setRestrictedJoinRule(roomID: String, spaceID: String) async -> Result<Void, RESTAPIError> {
        let request = RESTAPIRequest(
            method: .put,
            pathTemplate: "/_matrix/client/v3/rooms/%@/state/m.room.join_rules",
            pathParameters: [roomID],
            body: JoinRulesContent(joinRule: "restricted", allow: [JoinRuleAllowCondition(type: "m.room_membership", roomId: spaceID)])
        )
        return await execute(request)
    }

    func setPublicJoinRule(roomID: String) async -> Result<Void, RESTAPIError> {
        let request = RESTAPIRequest(
            method: .put,
            pathTemplate: "/_matrix/client/v3/rooms/%@/state/m.room.join_rules",
            pathParameters: [roomID],
            body: JoinRulesContent(joinRule: "public", allow: nil)
        )
        return await execute(request)
    }
}

// MARK: - Request Body Types

private struct SpaceChildContent: Encodable {
    let via: [String]
    let suggested: Bool
}

private struct SpaceParentContent: Encodable {
    let via: [String]
    let canonical: Bool
}

private struct JoinRulesContent: Encodable {
    let joinRule: String
    let allow: [JoinRuleAllowCondition]?

    enum CodingKeys: String, CodingKey {
        case joinRule = "join_rule"
        case allow
    }
}

private struct JoinRuleAllowCondition: Encodable {
    let type: String
    let roomId: String

    enum CodingKeys: String, CodingKey {
        case type
        case roomId = "room_id"
    }
}

private struct EmptyStateContent: Encodable { }
