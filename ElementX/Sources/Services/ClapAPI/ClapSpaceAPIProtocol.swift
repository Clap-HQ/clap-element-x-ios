//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

/// Details of a failed room operation
struct ClapSpaceRoomOperationFailure: Decodable {
    let roomId: String
    let error: String

    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case error
    }
}

/// Result of removing a member from space child rooms
struct ClapSpaceMemberRemovalResult: Decodable {
    /// Room IDs where the user was successfully removed
    let removed: [String]
    /// Rooms where removal failed with error details
    let failed: [ClapSpaceRoomOperationFailure]
}

/// Result of joining all child rooms in a space
struct ClapSpaceJoinAllResult: Decodable {
    /// Room IDs where the user successfully joined
    let joined: [String]
    /// Rooms where join failed with error details
    let failed: [ClapSpaceRoomOperationFailure]
}

// sourcery: AutoMockable
protocol ClapSpaceAPIProtocol {
    /// Removes a user from all child rooms of a space
    /// - Parameters:
    ///   - spaceID: The ID of the space
    ///   - userID: The Matrix ID of the user to remove
    /// - Returns: Result containing removed/failed room IDs or an error
    func removeMemberFromAllChildRooms(spaceID: String, userID: String) async -> Result<ClapSpaceMemberRemovalResult, ClapAPIError>

    /// Joins all child rooms in a space
    /// - Parameter spaceID: The ID of the space
    /// - Returns: Result containing joined/failed room IDs or an error
    func joinAllChildRooms(spaceID: String) async -> Result<ClapSpaceJoinAllResult, ClapAPIError>
}
