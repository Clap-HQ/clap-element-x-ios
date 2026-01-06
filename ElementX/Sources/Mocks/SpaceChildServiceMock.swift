//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

class SpaceChildServiceMock: SpaceChildServiceProtocol {
    var addChildToSpaceSpaceIDChildRoomIDSuggestedReturnValue: Result<Void, SpaceChildServiceError> = .success(())
    func addChildToSpace(spaceID: String, childRoomID: String, suggested: Bool) async -> Result<Void, SpaceChildServiceError> {
        addChildToSpaceSpaceIDChildRoomIDSuggestedReturnValue
    }

    var removeChildFromSpaceSpaceIDChildRoomIDReturnValue: Result<Void, SpaceChildServiceError> = .success(())
    func removeChildFromSpace(spaceID: String, childRoomID: String) async -> Result<Void, SpaceChildServiceError> {
        removeChildFromSpaceSpaceIDChildRoomIDReturnValue
    }

    var setSpaceParentRoomIDSpaceIDCanonicalReturnValue: Result<Void, SpaceChildServiceError> = .success(())
    func setSpaceParent(roomID: String, spaceID: String, canonical: Bool) async -> Result<Void, SpaceChildServiceError> {
        setSpaceParentRoomIDSpaceIDCanonicalReturnValue
    }

    var setRestrictedJoinRuleRoomIDSpaceIDReturnValue: Result<Void, SpaceChildServiceError> = .success(())
    func setRestrictedJoinRule(roomID: String, spaceID: String) async -> Result<Void, SpaceChildServiceError> {
        setRestrictedJoinRuleRoomIDSpaceIDReturnValue
    }

    var setPublicJoinRuleRoomIDReturnValue: Result<Void, SpaceChildServiceError> = .success(())
    func setPublicJoinRule(roomID: String) async -> Result<Void, SpaceChildServiceError> {
        setPublicJoinRuleRoomIDReturnValue
    }
}
