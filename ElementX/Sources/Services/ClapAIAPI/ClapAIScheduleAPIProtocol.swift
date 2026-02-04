//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

// MARK: - Schedule Status

enum ScheduleStatus: String, Codable, CaseIterable {
    case active
    case paused
    case pending
    case cancelled
    
    var displayName: String {
        switch self {
        case .active: return L10n.commonScheduleStatusActive
        case .paused: return L10n.commonScheduleStatusPaused
        case .pending: return L10n.commonScheduleStatusPending
        case .cancelled: return L10n.commonScheduleStatusCancelled
        }
    }
}

// MARK: - Schedule Model

struct Schedule: Identifiable, Decodable, Hashable {
    let id: Int64
    let name: String
    let roomID: String
    let cronExpression: String
    let timezone: String
    let prompt: String
    let userID: String
    let targetUser: String?
    let targetRoom: String?
    let isDM: Bool
    let status: ScheduleStatus
    let runCount: Int
    let lastRunAt: Date?
    let lastError: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "description"
        case roomID = "room_id"
        case cronExpression = "cron_expression"
        case timezone
        case prompt
        case userID = "user_id"
        case targetUser = "target_user"
        case targetRoom = "target_room"
        case isDM = "is_dm"
        case status
        case runCount = "run_count"
        case lastRunAt = "last_run_at"
        case lastError = "last_error"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - API Response Types

struct RunScheduleResponse: Decodable {
    let message: String
    let scheduleID: Int64
    
    enum CodingKeys: String, CodingKey {
        case message
        case scheduleID = "schedule_id"
    }
}

struct ScheduleHistoryEntry: Identifiable, Decodable, Hashable {
    let id: Int64
    let scheduleID: Int64
    let scheduleDescription: String?
    let response: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case scheduleID = "schedule_id"
        case scheduleDescription = "schedule_description"
        case response
        case createdAt = "created_at"
    }
}

// MARK: - Protocol

// sourcery: AutoMockable
protocol ClapAIScheduleAPIProtocol {
    /// Lists all schedules for the current user (or all for admins)
    func listSchedules() async -> Result<[Schedule], RESTAPIError>
    
    /// Gets a specific schedule by ID
    func getSchedule(id: Int64) async -> Result<Schedule, RESTAPIError>
    
    /// Creates a new schedule (admin only)
    func createSchedule(
        name: String,
        roomID: String,
        cronExpression: String,
        timezone: String,
        prompt: String,
        userID: String
    ) async -> Result<Schedule, RESTAPIError>
    
    /// Deletes a schedule (soft delete - sets status to cancelled)
    func deleteSchedule(id: Int64) async -> Result<Void, RESTAPIError>
    
    /// Triggers immediate execution of a schedule
    func runSchedule(id: Int64) async -> Result<RunScheduleResponse, RESTAPIError>
    
    /// Pauses an active schedule
    func pauseSchedule(id: Int64) async -> Result<Schedule, RESTAPIError>
    
    /// Resumes a paused schedule (admin only)
    func resumeSchedule(id: Int64) async -> Result<Schedule, RESTAPIError>
    
    /// Gets execution history for a schedule
    func getScheduleHistory(scheduleID: Int64, limit: Int) async -> Result<[ScheduleHistoryEntry], RESTAPIError>
}
