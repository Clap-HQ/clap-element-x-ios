//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

class ClapAIScheduleAPI: ClapAIRESTAPIClient, ClapAIScheduleAPIProtocol {
    func listSchedules() async -> Result<[Schedule], RESTAPIError> {
        let request = RESTAPIRequest(
            method: .get,
            pathTemplate: "/api/schedules"
        )
        return await execute(request)
    }
    
    func getSchedule(id: Int64) async -> Result<Schedule, RESTAPIError> {
        let request = RESTAPIRequest(
            method: .get,
            pathTemplate: "/api/schedules/%@",
            pathParameters: [String(id)]
        )
        return await execute(request)
    }
    
    func createSchedule(
        name: String,
        roomID: String,
        cronExpression: String,
        timezone: String,
        prompt: String,
        userID: String
    ) async -> Result<Schedule, RESTAPIError> {
        let request = RESTAPIRequest(
            method: .post,
            pathTemplate: "/api/schedules",
            body: CreateScheduleRequest(
                name: name,
                roomID: roomID,
                cronExpression: cronExpression,
                timezone: timezone,
                prompt: prompt,
                userID: userID
            )
        )
        return await execute(request)
    }
    
    func deleteSchedule(id: Int64) async -> Result<Void, RESTAPIError> {
        let request = RESTAPIRequest(
            method: .delete,
            pathTemplate: "/api/schedules/%@",
            pathParameters: [String(id)]
        )
        return await execute(request)
    }
    
    func runSchedule(id: Int64) async -> Result<RunScheduleResponse, RESTAPIError> {
        let request = RESTAPIRequest(
            method: .post,
            pathTemplate: "/api/schedules/%@/run",
            pathParameters: [String(id)]
        )
        return await execute(request)
    }
    
    func pauseSchedule(id: Int64) async -> Result<Schedule, RESTAPIError> {
        let request = RESTAPIRequest(
            method: .post,
            pathTemplate: "/api/schedules/%@/pause",
            pathParameters: [String(id)]
        )
        return await execute(request)
    }
    
    func resumeSchedule(id: Int64) async -> Result<Schedule, RESTAPIError> {
        let request = RESTAPIRequest(
            method: .post,
            pathTemplate: "/api/schedules/%@/resume",
            pathParameters: [String(id)]
        )
        return await execute(request)
    }
    
    func getScheduleHistory(scheduleID: Int64, limit: Int) async -> Result<[ScheduleHistoryEntry], RESTAPIError> {
        let request = RESTAPIRequest(
            method: .get,
            pathTemplate: "/api/logs",
            queryParameters: [
                "schedule_id": String(scheduleID),
                "limit": String(limit)
            ]
        )
        return await execute(request)
    }
}

private struct CreateScheduleRequest: Encodable {
    let name: String
    let roomID: String
    let cronExpression: String
    let timezone: String
    let prompt: String
    let userID: String
    
    enum CodingKeys: String, CodingKey {
        case name = "description"
        case roomID = "room_id"
        case cronExpression = "cron_expression"
        case timezone
        case prompt
        case userID = "user_id"
    }
}
