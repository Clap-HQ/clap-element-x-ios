//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

class MatrixAPIServiceMock: MatrixAPIServiceProtocol {
    var spaces: MatrixSpaceAPIProtocol = MatrixSpaceAPIMock()
    var threads: MatrixThreadsAPIProtocol = MatrixThreadsAPIMock()
}

class MatrixSpaceAPIMock: MatrixSpaceAPIProtocol {
    var addChildToSpaceResult: Result<Void, RESTAPIError> = .success(())
    var removeChildFromSpaceResult: Result<Void, RESTAPIError> = .success(())
    var setSpaceParentResult: Result<Void, RESTAPIError> = .success(())
    var setRestrictedJoinRuleResult: Result<Void, RESTAPIError> = .success(())
    var setPublicJoinRuleResult: Result<Void, RESTAPIError> = .success(())

    func addChildToSpace(spaceID: String, childRoomID: String, suggested: Bool) async -> Result<Void, RESTAPIError> {
        addChildToSpaceResult
    }

    func removeChildFromSpace(spaceID: String, childRoomID: String) async -> Result<Void, RESTAPIError> {
        removeChildFromSpaceResult
    }

    func setSpaceParent(roomID: String, spaceID: String, canonical: Bool) async -> Result<Void, RESTAPIError> {
        setSpaceParentResult
    }

    func setRestrictedJoinRule(roomID: String, spaceID: String) async -> Result<Void, RESTAPIError> {
        setRestrictedJoinRuleResult
    }

    func setPublicJoinRule(roomID: String) async -> Result<Void, RESTAPIError> {
        setPublicJoinRuleResult
    }
}

class MatrixThreadsAPIMock: MatrixThreadsAPIProtocol {
    var fetchThreadsResult: Result<ThreadListResponse, RESTAPIError> = .success(ThreadListResponse(chunk: [], nextBatch: nil))

    func fetchThreads(roomID: String, from: String?, include: ThreadIncludeFilter, limit: Int) async -> Result<ThreadListResponse, RESTAPIError> {
        fetchThreadsResult
    }
}
