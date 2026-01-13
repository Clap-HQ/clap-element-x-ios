//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

// sourcery: AutoMockable
protocol MatrixSpaceAPIProtocol {
    /// Adds a room as a child of a space by setting the m.space.child state event
    /// - Parameters:
    ///   - spaceID: The ID of the parent space
    ///   - childRoomID: The ID of the room to add as a child
    ///   - suggested: Whether the room should be marked as suggested for space members
    /// - Returns: Success or an error
    func addChildToSpace(spaceID: String, childRoomID: String, suggested: Bool) async -> Result<Void, MatrixAPIError>

    /// Removes a room from a space by setting an empty m.space.child state event
    /// - Parameters:
    ///   - spaceID: The ID of the parent space
    ///   - childRoomID: The ID of the room to remove
    /// - Returns: Success or an error
    func removeChildFromSpace(spaceID: String, childRoomID: String) async -> Result<Void, MatrixAPIError>

    /// Sets the parent space for a room by setting the m.space.parent state event
    /// - Parameters:
    ///   - roomID: The ID of the child room
    ///   - spaceID: The ID of the parent space
    ///   - canonical: Whether this is the canonical parent space
    /// - Returns: Success or an error
    func setSpaceParent(roomID: String, spaceID: String, canonical: Bool) async -> Result<Void, MatrixAPIError>

    /// Sets the join rules for a room (restricted to space members)
    /// - Parameters:
    ///   - roomID: The ID of the room
    ///   - spaceID: The ID of the parent space (for restricted access)
    /// - Returns: Success or an error
    func setRestrictedJoinRule(roomID: String, spaceID: String) async -> Result<Void, MatrixAPIError>

    /// Sets the join rules for a room to public
    /// - Parameters:
    ///   - roomID: The ID of the room
    /// - Returns: Success or an error
    func setPublicJoinRule(roomID: String) async -> Result<Void, MatrixAPIError>
}
