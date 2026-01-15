//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

class ClapAPIServiceMock: ClapAPIServiceProtocol {
    var spaces: ClapSpaceAPIProtocol = ClapSpaceAPIMock()
}

class ClapSpaceAPIMock: ClapSpaceAPIProtocol {
    var removeMemberFromAllChildRoomsResult: Result<ClapSpaceMemberRemovalResult, RESTAPIError> = .success(.init(removed: [], failed: []))
    var joinAllChildRoomsResult: Result<ClapSpaceJoinAllResult, RESTAPIError> = .success(.init(joined: [], failed: []))

    func removeMemberFromAllChildRooms(spaceID: String, userID: String) async -> Result<ClapSpaceMemberRemovalResult, RESTAPIError> {
        removeMemberFromAllChildRoomsResult
    }

    func joinAllChildRooms(spaceID: String) async -> Result<ClapSpaceJoinAllResult, RESTAPIError> {
        joinAllChildRoomsResult
    }
}
