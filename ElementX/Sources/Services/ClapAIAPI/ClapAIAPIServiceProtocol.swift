//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

struct ClapAIUser: Codable, Equatable {
    let userID: String
    let role: String
    
    var isAdmin: Bool {
        role == "admin"
    }
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case role
    }
}

// sourcery: AutoMockable
protocol ClapAIAPIServiceProtocol {
    var schedules: ClapAIScheduleAPIProtocol { get }
    var currentUser: ClapAIUser? { get }
    func ensureAuthenticated() async -> Result<Void, RESTAPIError>
    func fetchCurrentUser() async -> Result<ClapAIUser, RESTAPIError>
    func invalidateToken()
}
