//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

class MatrixAPIServiceMock: MatrixAPIServiceProtocol {
    var spaces: MatrixSpaceAPIProtocol = MatrixSpaceAPIMock()
}

class MatrixSpaceAPIMock: MatrixSpaceAPIProtocol {
    var addChildToSpaceResult: Result<Void, MatrixAPIError> = .success(())
    var removeChildFromSpaceResult: Result<Void, MatrixAPIError> = .success(())
    var setSpaceParentResult: Result<Void, MatrixAPIError> = .success(())
    var setRestrictedJoinRuleResult: Result<Void, MatrixAPIError> = .success(())
    var setPublicJoinRuleResult: Result<Void, MatrixAPIError> = .success(())

    func addChildToSpace(spaceID: String, childRoomID: String, suggested: Bool) async -> Result<Void, MatrixAPIError> {
        addChildToSpaceResult
    }

    func removeChildFromSpace(spaceID: String, childRoomID: String) async -> Result<Void, MatrixAPIError> {
        removeChildFromSpaceResult
    }

    func setSpaceParent(roomID: String, spaceID: String, canonical: Bool) async -> Result<Void, MatrixAPIError> {
        setSpaceParentResult
    }

    func setRestrictedJoinRule(roomID: String, spaceID: String) async -> Result<Void, MatrixAPIError> {
        setRestrictedJoinRuleResult
    }

    func setPublicJoinRule(roomID: String) async -> Result<Void, MatrixAPIError> {
        setPublicJoinRuleResult
    }
}
