//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct ScheduleRoomPickerView: View {
    let rooms: [RoomSummary]
    let directMessages: [RoomSummary]
    let selectedRoom: RoomSummary?
    let onSelect: (RoomSummary) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                if !rooms.isEmpty {
                    Section(L10n.screenScheduleRoomPickerSectionRooms) {
                        ForEach(sortedRooms, id: \.id) { room in
                            roomRow(room)
                        }
                    }
                }
                
                if !directMessages.isEmpty {
                    Section(L10n.screenScheduleRoomPickerSectionDm) {
                        ForEach(sortedDirectMessages, id: \.id) { room in
                            roomRow(room)
                        }
                    }
                }
            }
            .compoundList()
            .navigationTitle(L10n.screenScheduleRoomPickerTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.actionCancel) {
                        onCancel()
                    }
                }
            }
        }
    }
    
    private var sortedRooms: [RoomSummary] {
        rooms.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    private var sortedDirectMessages: [RoomSummary] {
        directMessages.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    private func roomRow(_ room: RoomSummary) -> some View {
        Button {
            onSelect(room)
        } label: {
            HStack(spacing: 8) {
                Text(room.name)
                    .foregroundColor(.compound.textPrimary)
                
                Spacer()
                
                if selectedRoom?.id == room.id {
                    Image(systemName: "checkmark")
                        .foregroundColor(.compound.iconAccentTertiary)
                }
            }
        }
    }
}
